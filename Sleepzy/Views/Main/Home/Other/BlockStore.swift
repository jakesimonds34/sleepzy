import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import BackgroundTasks
import Combine
import os.log

// MARK: - AppGroupConfig

enum AppGroupConfig {
    static let suiteName    = "group.com.timescreen.app"
    static let schedulesKey = "scheduleBlocks_v2"
    static let timersKey    = "timerBlocks_v2"
    static let shieldKey    = "digitalShield_v2"

    static func selectionKey(for name: String) -> String { "selection_\(name)" }
    static var sharedDefaults: UserDefaults { UserDefaults(suiteName: suiteName)! }
}

// MARK: - BlockStore

@MainActor
final class BlockStore: ObservableObject {

    static let shared = BlockStore()
    private let logger = Logger(subsystem: "com.timescreen.app", category: "BlockStore")

    // MARK: Published
    @Published var scheduleBlocks: [ScheduleBlock] = []
    @Published var timerBlocks:    [TimerBlock]    = []
    @Published var digitalShield:  DigitalShield?
    @Published var sleepDuration:  String = "7 Hr 15 min"

    // MARK: Private
    // One named store per block — prevents blocks from overwriting each other
    private func store(for name: String) -> ManagedSettingsStore {
        ManagedSettingsStore(named: ManagedSettingsStore.Name(rawValue: name))
    }

    private let activityCenter = DeviceActivityCenter()
    private let defaults       = AppGroupConfig.sharedDefaults
    private var checkTimer:    Timer?

    private init() {
        loadAll()
        setupDefaultShieldIfNeeded()
        startPeriodicCheck()     // checks every minute if a block should be active
    }

    // MARK: - SCHEDULE CRUD

    func addScheduleBlock(_ block: ScheduleBlock) {
        scheduleBlocks.append(block)
        save()
        persistSelection(block.appSelection, key: AppGroupConfig.selectionKey(for: block.id.uuidString))
        registerDeviceActivity(for: block)
        evaluateScheduleBlock(block) // apply immediately if inside window
    }

    func updateScheduleBlock(_ block: ScheduleBlock) {
        guard let idx = scheduleBlocks.firstIndex(where: { $0.id == block.id }) else { return }
        activityCenter.stopMonitoring([DeviceActivityName(block.id.uuidString)])
        clearShield(name: block.id.uuidString)
        scheduleBlocks[idx] = block
        save()
        persistSelection(block.appSelection, key: AppGroupConfig.selectionKey(for: block.id.uuidString))
        if block.isEnabled {
            registerDeviceActivity(for: block)
            evaluateScheduleBlock(block)
        }
    }

    func removeScheduleBlock(id: UUID) {
        activityCenter.stopMonitoring([DeviceActivityName(id.uuidString)])
        clearShield(name: id.uuidString)
        scheduleBlocks.removeAll { $0.id == id }
        save()
    }

    func toggleScheduleBlock(id: UUID) {
        guard let idx = scheduleBlocks.firstIndex(where: { $0.id == id }) else { return }
        scheduleBlocks[idx].isEnabled.toggle()
        let block = scheduleBlocks[idx]
        save()
        if block.isEnabled {
            registerDeviceActivity(for: block)
            evaluateScheduleBlock(block)
        } else {
            activityCenter.stopMonitoring([DeviceActivityName(id.uuidString)])
            clearShield(name: id.uuidString)
        }
    }

    // MARK: - TIMER CRUD

    func addTimerBlock(_ block: TimerBlock) {
        timerBlocks.append(block)
        save()
        persistSelection(block.appSelection, key: AppGroupConfig.selectionKey(for: "timer-\(block.id.uuidString)"))
    }

    func startTimerBlock(id: UUID) {
        guard let idx = timerBlocks.firstIndex(where: { $0.id == id }) else { return }
        timerBlocks[idx].startedAt = Date()
        let block = timerBlocks[idx]
        save()
        // Apply shield immediately
        applyShield(name: "timer-\(id.uuidString)", selection: block.appSelection)
        // Schedule removal after duration
        let actName = DeviceActivityName("timer-\(id.uuidString)")
        let now = Date()
        let end = Calendar.current.date(byAdding: .minute, value: block.durationMinutes, to: now)!
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd:   Calendar.current.dateComponents([.hour, .minute, .second], from: end),
            repeats: false
        )
        try? activityCenter.startMonitoring(actName, during: schedule)
    }

    func stopTimerBlock(id: UUID) {
        guard let idx = timerBlocks.firstIndex(where: { $0.id == id }) else { return }
        timerBlocks[idx].startedAt = nil
        save()
        activityCenter.stopMonitoring([DeviceActivityName("timer-\(id.uuidString)")])
        clearShield(name: "timer-\(id.uuidString)")
    }

    func removeTimerBlock(id: UUID) {
        activityCenter.stopMonitoring([DeviceActivityName("timer-\(id.uuidString)")])
        clearShield(name: "timer-\(id.uuidString)")
        timerBlocks.removeAll { $0.id == id }
        save()
    }

    // MARK: - DIGITAL SHIELD

    func updateDigitalShield(_ shield: DigitalShield) {
        digitalShield = shield
        save()
        persistSelection(shield.appSelection, key: AppGroupConfig.selectionKey(for: "digitalShield"))
        if shield.isEnabled { registerShieldActivity(shield) }
        evaluateShield(shield)
    }

    func toggleShield() {
        guard var shield = digitalShield else { return }
        shield.isEnabled.toggle()
        digitalShield = shield
        save()
        if shield.isEnabled {
            persistSelection(shield.appSelection, key: AppGroupConfig.selectionKey(for: "digitalShield"))
            registerShieldActivity(shield)
            evaluateShield(shield)
        } else {
            activityCenter.stopMonitoring([DeviceActivityName("digitalShield")])
            clearShield(name: "digitalShield")
        }
    }

    // MARK: - CORE BLOCKING ENGINE
    //
    // WHY THIS APPROACH:
    // DeviceActivityMonitor.intervalDidStart only fires reliably when DeviceActivityEvents
    // with thresholds are registered — not for pure schedule monitoring.
    // The correct pattern for app blocking is:
    //   1. Register DeviceActivitySchedule (so system knows the window)
    //   2. Apply ManagedSettingsStore.shield DIRECTLY from the app when inside window
    //   3. Use a periodic timer + DeviceActivityMonitor as backup for cleanup
    //
    // ManagedSettingsStore persists across app restarts — the shield stays
    // even if the app is killed, until explicitly cleared.

    /// Apply shield directly — this is what actually blocks the apps
    private func applyShield(name: String, selection: FamilyActivitySelection) {
        let s = store(for: name)
        s.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        s.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        s.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
        logger.info("🛡 Shield ON  [\(name)] apps=\(selection.applicationTokens.count) cats=\(selection.categoryTokens.count)")
    }

    /// Remove shield — called when block window ends
    private func clearShield(name: String) {
        let s = store(for: name)
        s.shield.applications          = nil
        s.shield.applicationCategories = nil
        s.shield.webDomains            = nil
        logger.info("🔓 Shield OFF [\(name)]")
    }

    // MARK: - Window Evaluation (is current time inside block window?)

    /// Called on add, toggle, and every minute via timer
    func evaluateAllBlocks() {
        for block in scheduleBlocks where block.isEnabled {
            evaluateScheduleBlock(block)
        }
        if let shield = digitalShield, shield.isEnabled {
            evaluateShield(shield)
        }
        // Running timers: clear if expired
        for block in timerBlocks where block.isRunning {
            if let secs = block.remainingSeconds, secs <= 0 {
                stopTimerBlock(id: block.id)
            }
        }
    }

    private func evaluateScheduleBlock(_ block: ScheduleBlock) {
        guard block.isEnabled else { clearShield(name: block.id.uuidString); return }
        if isCurrentlyInWindow(from: block.fromTime, to: block.toTime) {
            applyShield(name: block.id.uuidString, selection: block.appSelection)
        } else {
            clearShield(name: block.id.uuidString)
        }
    }

    private func evaluateShield(_ shield: DigitalShield) {
        guard shield.isEnabled else { clearShield(name: "digitalShield"); return }
        if isCurrentlyInWindow(from: shield.startTime, to: shield.endTime) {
            applyShield(name: "digitalShield", selection: shield.appSelection)
        } else {
            clearShield(name: "digitalShield")
        }
    }

    /// Returns true if current time (hour:minute) falls inside [from, to).
    /// Handles overnight windows e.g. 22:00 → 08:00.
    private func isCurrentlyInWindow(from: DateComponents, to: DateComponents) -> Bool {
        let cal  = Calendar.current
        let now  = cal.dateComponents([.hour, .minute], from: Date())
        let nowM = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let frM  = (from.hour ?? 0) * 60 + (from.minute ?? 0)
        let toM  = (to.hour ?? 0) * 60 + (to.minute ?? 0)

        if frM < toM {
            // same-day window e.g. 09:00 → 17:00
            return nowM >= frM && nowM < toM
        } else {
            // overnight window e.g. 22:00 → 08:00
            return nowM >= frM || nowM < toM
        }
    }

    // MARK: - Periodic Timer (every 60s)
    // Ensures blocks are applied/removed even when DeviceActivityMonitor doesn't fire

    private func startPeriodicCheck() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.evaluateAllBlocks()
            }
        }
        RunLoop.main.add(checkTimer!, forMode: .common)
        // Also evaluate immediately on init
        evaluateAllBlocks()
    }

    // MARK: - DeviceActivity Registration
    // Registers the schedule so the Extension can ALSO apply the shield
    // as a redundancy layer (e.g. after device restart when app is not running)

    private func registerDeviceActivity(for block: ScheduleBlock) {
        guard block.isEnabled else { return }
        let name = DeviceActivityName(block.id.uuidString)
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: block.fromTime.hour, minute: block.fromTime.minute),
            intervalEnd:   DateComponents(hour: block.toTime.hour,   minute: block.toTime.minute),
            repeats: true
        )
        do {
            try activityCenter.startMonitoring(name, during: schedule)
        } catch {
            logger.error("DeviceActivity registration failed: \(error.localizedDescription)")
        }
    }

    private func registerShieldActivity(_ shield: DigitalShield) {
        let name = DeviceActivityName("digitalShield")
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: shield.startTime.hour, minute: shield.startTime.minute),
            intervalEnd:   DateComponents(hour: shield.endTime.hour,   minute: shield.endTime.minute),
            repeats: true
        )
        try? activityCenter.startMonitoring(name, during: schedule)
    }

    // MARK: - Persistence

    private func persistSelection(_ selection: FamilyActivitySelection, key: String) {
        if let data = try? JSONEncoder().encode(selection) {
            defaults.set(data, forKey: key)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(scheduleBlocks) {
            defaults.set(data, forKey: AppGroupConfig.schedulesKey)
        }
        if let data = try? JSONEncoder().encode(timerBlocks) {
            defaults.set(data, forKey: AppGroupConfig.timersKey)
        }
    }

    private func loadAll() {
        if let data    = defaults.data(forKey: AppGroupConfig.schedulesKey),
           let decoded = try? JSONDecoder().decode([ScheduleBlock].self, from: data) {
            scheduleBlocks = decoded
            for block in scheduleBlocks where block.isEnabled {
                registerDeviceActivity(for: block)
                persistSelection(
                    block.appSelection,
                    key: AppGroupConfig.selectionKey(for: block.id.uuidString)
                )
            }
        }
        if let data    = defaults.data(forKey: AppGroupConfig.timersKey),
           let decoded = try? JSONDecoder().decode([TimerBlock].self, from: data) {
            timerBlocks = decoded
        }
    }

    private func setupDefaultShieldIfNeeded() {
        if digitalShield == nil {
            digitalShield = DigitalShield(
                startTime:    DateComponents(hour: 22, minute: 30),
                endTime:      DateComponents(hour: 8,  minute: 0),
                appSelection: FamilyActivitySelection()
            )
        }
    }
}

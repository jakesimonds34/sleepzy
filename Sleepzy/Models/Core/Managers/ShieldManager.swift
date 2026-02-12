//
//  ShieldManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// MARK: - Schedule Type Enum
//enum ScheduleType: String, Codable {
//    case allDay = "All Day"
//    case nightTime = "Night Time"
//    case custom = "Custom"
//}

// MARK: - Timer Duration Enum
//enum TimerDuration: String, Codable {
//    case fifteenMin = "15 Minutes"
//    case thirtyMin = "30 Minutes"
//    case oneHour = "1 Hour"
//    case twoHours = "2 Hours"
//    case custom = "Custom"
//    
//    var minutes: Int {
//        switch self {
//        case .fifteenMin: return 15
//        case .thirtyMin: return 30
//        case .oneHour: return 60
//        case .twoHours: return 120
//        case .custom: return 0
//        }
//    }
//}

// MARK: - Shield Manager
/// Central manager for all blocking and restriction operations
class ShieldManager: ObservableObject {
    static let shared = ShieldManager()
    
    // MARK: - Published Properties
    @Published var isShieldActive = false
    @Published var currentSchedule: ScheduleType?
    @Published var activeTimers: [TimerInfo] = []
    
    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    private var timerCancellables: [UUID: AnyCancellable] = [:]
    
    private init() {
        loadShieldState()
    }
    
    // MARK: - Apply Shield Methods
    
    /// Apply complete 24/7 block
    func applyAllDayBlock(selection: FamilyActivitySelection) {
        guard selection.applicationTokens.isEmpty == false ||
              selection.categoryTokens.isEmpty == false else {
            print("⚠️ No apps or categories selected")
            return
        }
        
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        isShieldActive = true
        currentSchedule = .allDay
        saveShieldState()
        
        print("✅ All-day block applied")
    }
    
    /// Apply scheduled block (e.g., bedtime)
    func applyScheduledBlock(
        selection: FamilyActivitySelection,
        schedule: ScheduleType,
        startHour: Int = 22,
        startMinute: Int = 0,
        endHour: Int = 7,
        endMinute: Int = 0
    ) {
        guard selection.applicationTokens.isEmpty == false ||
              selection.categoryTokens.isEmpty == false else {
            print("⚠️ No apps or categories selected")
            return
        }
        
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        let deviceSchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMinute),
            intervalEnd: DateComponents(hour: endHour, minute: endMinute),
            repeats: true
        )
        
        let activityName = DeviceActivityName("schedule_\(UUID().uuidString)")
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: deviceSchedule)
            isShieldActive = true
            currentSchedule = schedule
            saveShieldState()
            print("✅ Scheduled block applied: \(startHour):\(startMinute) - \(endHour):\(endMinute)")
        } catch {
            print("❌ Failed to start monitoring: \(error.localizedDescription)")
        }
    }
    
    /// Apply timer-based block
    func applyTimerBlock(
        selection: FamilyActivitySelection,
        duration: TimerDuration,
        customMinutes: Int = 60,
        blockId: UUID
    ) {
        guard selection.applicationTokens.isEmpty == false ||
              selection.categoryTokens.isEmpty == false else {
            print("⚠️ No apps or categories selected")
            return
        }
        
        let minutes = duration == .custom ? customMinutes : duration.minutes
        
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        let endTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
        
        // Add to active timers
        let timerInfo = TimerInfo(
            id: blockId,
            endTime: endTime,
            durationMinutes: minutes
        )
        activeTimers.append(timerInfo)
        
        // Schedule automatic removal
        let cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTimerExpiration(blockId: blockId)
            }
        
        timerCancellables[blockId] = cancellable
        
        isShieldActive = true
        currentSchedule = .custom
        saveShieldState()
        
        print("✅ Timer block applied: \(minutes) minutes")
    }
    
    // MARK: - Remove Shield Methods
    
    /// Remove all restrictions
    func removeAllRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        deviceActivityCenter.stopMonitoring()
        
        // Cancel all timers
        timerCancellables.values.forEach { $0.cancel() }
        timerCancellables.removeAll()
        activeTimers.removeAll()
        
        isShieldActive = false
        currentSchedule = nil
        saveShieldState()
        
        print("✅ All restrictions removed")
    }
    
    /// Remove specific schedule
    func removeSchedule(_ name: String) {
        let activityName = DeviceActivityName(name)
        deviceActivityCenter.stopMonitoring([activityName])
        print("✅ Schedule '\(name)' removed")
    }
    
    /// Cancel specific timer
    func cancelTimer(blockId: UUID) {
        timerCancellables[blockId]?.cancel()
        timerCancellables.removeValue(forKey: blockId)
        activeTimers.removeAll { $0.id == blockId }
        
        // If no more timers, remove shield
        if activeTimers.isEmpty {
            removeAllRestrictions()
        }
        
        print("✅ Timer cancelled for block: \(blockId)")
    }
    
    // MARK: - Check Methods
    
    /// Check if app is blocked
    func isAppBlocked(_ token: ApplicationToken) -> Bool {
        guard let blockedApps = store.shield.applications else {
            return false
        }
        return blockedApps.contains(token)
    }
    
    /// Get count of blocked apps
    func getBlockedAppsCount() -> Int {
        return store.shield.applications?.count ?? 0
    }
    
    /// Get remaining time for timer
    func getRemainingTime(for blockId: UUID) -> TimeInterval? {
        guard let timer = activeTimers.first(where: { $0.id == blockId }) else {
            return nil
        }
        return timer.endTime.timeIntervalSince(Date())
    }
    
    // MARK: - Private Methods
    
    private func checkTimerExpiration(blockId: UUID) {
        guard let timer = activeTimers.first(where: { $0.id == blockId }) else {
            return
        }
        
        if Date() >= timer.endTime {
            cancelTimer(blockId: blockId)
            NotificationCenter.default.post(
                name: .timerExpired,
                object: nil,
                userInfo: ["blockId": blockId]
            )
            print("⏱️ Timer expired for block: \(blockId)")
        }
    }
    
    // MARK: - State Persistence
    
    private func saveShieldState() {
        UserDefaults.standard.set(isShieldActive, forKey: "isShieldActive")
        if let schedule = currentSchedule {
            UserDefaults.standard.set(schedule.rawValue, forKey: "currentSchedule")
        }
    }
    
    private func loadShieldState() {
        isShieldActive = UserDefaults.standard.bool(forKey: "isShieldActive")
        if let scheduleString = UserDefaults.standard.string(forKey: "currentSchedule"),
           let schedule = ScheduleType(rawValue: scheduleString) {
            currentSchedule = schedule
        }
    }
}

// MARK: - Timer Info Model
struct TimerInfo: Identifiable {
    let id: UUID
    let endTime: Date
    let durationMinutes: Int
    
    var remainingSeconds: Int {
        max(0, Int(endTime.timeIntervalSince(Date())))
    }
    
    var remainingMinutes: Int {
        remainingSeconds / 60
    }
    
    var formattedTimeRemaining: String {
        let minutes = remainingMinutes
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let timerExpired = Notification.Name("timerExpired")
    static let blockActivated = Notification.Name("blockActivated")
    static let blockDeactivated = Notification.Name("blockDeactivated")
}

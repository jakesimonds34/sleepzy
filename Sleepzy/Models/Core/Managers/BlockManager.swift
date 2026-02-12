//
//  BlockManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI
import Combine

// MARK: - Block Manager
/// Central manager for all block CRUD operations
class BlockManager: ObservableObject {
    static let shared = BlockManager()
    
    // MARK: - Published Properties
    @Published var blocks: [SavedBlock] = []
    @Published var activeBlocks: [SavedBlock] = []
    @Published var upcomingBlocks: [UpcomingBlock] = []
    
    // MARK: - Private Properties
    private let shieldManager = ShieldManager.shared
    private let userDefaults = UserDefaults.standard
    private let blocksKey = "savedBlocks"
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    private init() {
        loadBlocks()
        updateActiveBlocks()
        updateUpcomingBlocks()
        startPeriodicUpdates()
    }
    
    // MARK: - Public Methods
    
    /// Add new block
    func addBlock(_ configuration: BlockConfiguration) {
        let block = SavedBlock(
            id: UUID(),
            configuration: configuration,
            isActive: false,
            createdAt: Date()
        )
        
        blocks.append(block)
        saveBlocks()
        
        // Activate if current time is within range
        if shouldActivateNow(block) {
            activateBlock(block)
        }
        
        updateUpcomingBlocks()
        
        NotificationCenter.default.post(name: .blockCreated, object: block)
        print("✅ Block added: \(configuration.name)")
    }
    
    /// Activate specific block
    func activateBlock(_ block: SavedBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        let config = block.configuration
        
        if config.type == .schedule {
            applyScheduleBlock(config)
        } else {
            applyTimerBlock(config, blockId: block.id)
        }
        
        blocks[index].isActive = true
        blocks[index].lastActivated = Date()
        updateActiveBlocks()
        saveBlocks()
        
        NotificationCenter.default.post(name: .blockActivated, object: block)
        print("✅ Block activated: \(config.name)")
    }
    
    /// Deactivate specific block
    func deactivateBlock(_ block: SavedBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        let config = block.configuration
        
        if config.type == .timer {
            shieldManager.cancelTimer(blockId: block.id)
        } else {
            // For schedule blocks, only remove if it's the only active block
            let otherActiveBlocks = activeBlocks.filter { $0.id != block.id }
            if otherActiveBlocks.isEmpty {
                shieldManager.removeAllRestrictions()
            }
        }
        
        blocks[index].isActive = false
        updateActiveBlocks()
        saveBlocks()
        
        NotificationCenter.default.post(name: .blockDeactivated, object: block)
        print("✅ Block deactivated: \(block.configuration.name)")
    }
    
    /// Delete block
    func deleteBlock(_ block: SavedBlock) {
        if block.isActive {
            deactivateBlock(block)
        }
        
        blocks.removeAll { $0.id == block.id }
        saveBlocks()
        updateUpcomingBlocks()
        
        NotificationCenter.default.post(name: .blockDeleted, object: block)
        print("✅ Block deleted: \(block.configuration.name)")
    }
    
    /// Update existing block
    func updateBlock(_ block: SavedBlock, with newConfiguration: BlockConfiguration) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        if blocks[index].isActive {
            deactivateBlock(block)
        }
        
        blocks[index].configuration = newConfiguration
        blocks[index].updatedAt = Date()
        
        if shouldActivateNow(blocks[index]) {
            activateBlock(blocks[index])
        }
        
        saveBlocks()
        updateUpcomingBlocks()
        
        NotificationCenter.default.post(name: .blockUpdated, object: blocks[index])
        print("✅ Block updated: \(newConfiguration.name)")
    }
    
    /// Get all active blocks
    func getActiveBlocks() -> [SavedBlock] {
        return blocks.filter { $0.isActive }
    }
    
    /// Get schedule blocks
    func getScheduleBlocks() -> [SavedBlock] {
        return blocks.filter { $0.configuration.type == .schedule }
    }
    
    /// Get timer blocks
    func getTimerBlocks() -> [SavedBlock] {
        return blocks.filter { $0.configuration.type == .timer }
    }
    
    /// Get blocks containing specific app
    func getBlocksContaining(appToken: ApplicationToken) -> [SavedBlock] {
        return blocks.filter { block in
            block.configuration.selectedApps.applicationTokens.contains(appToken)
        }
    }
    
    /// Get all blocked apps across all active blocks
    func getAllBlockedApps() -> Set<ApplicationToken> {
        var allApps = Set<ApplicationToken>()
        for block in activeBlocks {
            allApps.formUnion(block.configuration.selectedApps.applicationTokens)
        }
        return allApps
    }
    
    // MARK: - Private Methods
    
    private func applyScheduleBlock(_ config: BlockConfiguration) {
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        let endHour = convertTo24Hour(hour: config.toHour, period: config.toPeriod)
        
        shieldManager.applyScheduledBlock(
            selection: config.selectedApps,
            schedule: .custom,
            startHour: startHour,
            startMinute: config.fromMinute,
            endHour: endHour,
            endMinute: config.toMinute
        )
    }
    
    private func applyTimerBlock(_ config: BlockConfiguration, blockId: UUID) {
        shieldManager.applyTimerBlock(
            selection: config.selectedApps,
            duration: .custom,
            customMinutes: config.durationMinutes,
            blockId: blockId
        )
    }
    
    private func shouldActivateNow(_ block: SavedBlock) -> Bool {
        let config = block.configuration
        
        if config.type == .schedule {
            return isWithinScheduleTime(config)
        }
        
        return false
    }
    
    private func isWithinScheduleTime(_ config: BlockConfiguration) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Check day
        let currentWeekday = calendar.component(.weekday, from: now)
        let weekdayMapping: [Int: WeekDay] = [
            2: .monday, 3: .tuesday, 4: .wednesday, 5: .thursday, 6: .friday, 7: .saturday, 1: .sunday
        ]
        
        guard let currentDay = weekdayMapping[currentWeekday],
              config.selectedDays.contains(currentDay) else {
            return false
        }
        
        // Check time
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentMinutes = currentHour * 60 + currentMinute
        
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        let endHour = convertTo24Hour(hour: config.toHour, period: config.toPeriod)
        
        let startMinutes = startHour * 60 + config.fromMinute
        let endMinutes = endHour * 60 + config.toMinute
        
        if startMinutes < endMinutes {
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            return currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
    }
    
    private func convertTo24Hour(hour: Int, period: Period) -> Int {
        if period == .am {
            return hour == 12 ? 0 : hour
        } else {
            return hour == 12 ? 12 : hour + 12
        }
    }
    
    private func checkAndActivateBlocks() {
        for block in blocks {
            if !block.isActive && shouldActivateNow(block) {
                activateBlock(block)
            } else if block.isActive && !shouldActivateNow(block) && block.configuration.type == .schedule {
                deactivateBlock(block)
            }
        }
    }
    
    private func updateActiveBlocks() {
        activeBlocks = blocks.filter { $0.isActive }
    }
    
    private func updateUpcomingBlocks() {
        var upcoming: [UpcomingBlock] = []
        let calendar = Calendar.current
        let now = Date()
        
        for block in blocks.filter({ $0.configuration.type == .schedule }) {
            let config = block.configuration
            
            if let nextTime = getNextBlockTime(config, from: now) {
                let timeInterval = nextTime.timeIntervalSince(now)
                let minutes = Int(timeInterval / 60)
                
                if minutes > 0 && minutes < 1440 {
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    
                    let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
                    let endHour = convertTo24Hour(hour: config.toHour, period: config.toPeriod)
                    
                    var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
                    startComponents.hour = startHour
                    startComponents.minute = config.fromMinute
                    
                    var endComponents = calendar.dateComponents([.year, .month, .day], from: now)
                    endComponents.hour = endHour
                    endComponents.minute = config.toMinute
                    
                    if let startDate = calendar.date(from: startComponents),
                       let endDate = calendar.date(from: endComponents) {
                        
                        upcoming.append(UpcomingBlock(
                            name: config.name,
                            timeRemaining: "\(minutes)",
                            startTime: formatter.string(from: startDate),
                            endTime: formatter.string(from: endDate)
                        ))
                    }
                }
            }
        }
        
        upcomingBlocks = upcoming.sorted {
            Int($0.timeRemaining) ?? 0 < Int($1.timeRemaining) ?? 0
        }
    }
    
    private func getNextBlockTime(_ config: BlockConfiguration, from date: Date) -> Date? {
        let calendar = Calendar.current
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = startHour
        components.minute = config.fromMinute
        
        if let nextTime = calendar.date(from: components), nextTime > date {
            return nextTime
        }
        
        for dayOffset in 1...7 {
            if let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                components = calendar.dateComponents([.year, .month, .day], from: futureDate)
                components.hour = startHour
                components.minute = config.fromMinute
                
                if let nextTime = calendar.date(from: components) {
                    let weekday = calendar.component(.weekday, from: nextTime)
                    let weekdayMapping: [Int: WeekDay] = [
                        2: .monday, 3: .tuesday, 4: .wednesday, 5: .thursday, 6: .friday, 7: .saturday, 1: .sunday
                    ]
                    
                    if let day = weekdayMapping[weekday], config.selectedDays.contains(day) {
                        return nextTime
                    }
                }
            }
        }
        
        return nil
    }
    
    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkAndActivateBlocks()
            self?.updateUpcomingBlocks()
        }
    }
    
    // MARK: - Persistence
    
    private func saveBlocks() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(blocks)
            userDefaults.set(data, forKey: blocksKey)
        } catch {
            print("❌ Failed to save blocks: \(error.localizedDescription)")
        }
    }
    
    private func loadBlocks() {
        guard let data = userDefaults.data(forKey: blocksKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            blocks = try decoder.decode([SavedBlock].self, from: data)
        } catch {
            print("❌ Failed to load blocks: \(error.localizedDescription)")
        }
    }
    
    func clearAllBlocks() {
        for block in activeBlocks {
            deactivateBlock(block)
        }
        
        blocks.removeAll()
        saveBlocks()
        updateUpcomingBlocks()
        
        print("✅ All blocks cleared")
    }
    
    // MARK: - Quick Actions
    
    func createQuickNightBlock(apps: FamilyActivitySelection) {
        let config = BlockConfiguration(
            name: "Night Time",
            type: .schedule,
            fromHour: 10,
            fromMinute: 0,
            fromPeriod: .pm,
            toHour: 7,
            toMinute: 0,
            toPeriod: .am,
            selectedDays: Set(WeekDay.allCases),
            durationMinutes: 0,
            selectedApps: apps,
            brakeType: .takeItEasy
        )
        addBlock(config)
    }
    
    func createQuickFocusTimer(apps: FamilyActivitySelection, minutes: Int = 60) {
        let config = BlockConfiguration(
            name: "Focus Time",
            type: .timer,
            fromHour: 0,
            fromMinute: 0,
            fromPeriod: .am,
            toHour: 0,
            toMinute: 0,
            toPeriod: .am,
            selectedDays: [],
            durationMinutes: minutes,
            selectedApps: apps,
            brakeType: .makeItHarder
        )
        addBlock(config)
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> BlockStatistics {
        BlockStatistics(
            totalBlocks: blocks.count,
            activeBlocks: activeBlocks.count,
            scheduleBlocks: blocks.filter { $0.configuration.type == .schedule }.count,
            timerBlocks: blocks.filter { $0.configuration.type == .timer }.count
        )
    }
}

// MARK: - Block Statistics Model
struct BlockStatistics {
    let totalBlocks: Int
    let activeBlocks: Int
    let scheduleBlocks: Int
    let timerBlocks: Int
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let blockCreated = Notification.Name("blockCreated")
    static let blockUpdated = Notification.Name("blockUpdated")
    static let blockDeleted = Notification.Name("blockDeleted")
}

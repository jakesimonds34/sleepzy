//
//  BlockingManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

/*
import Foundation
import ManagedSettings
import FamilyControls
import Combine

final class BlockingManager: ObservableObject {
    static let shared = BlockingManager()

    private let store = ManagedSettingsStore()

    func applyBlocking(for selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = nil
    }

    func clearBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
*/

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI
import Combine

// MARK: - Block Manager
/// مدير مركزي لإدارة جميع الكتل (Blocks) المحفوظة والنشطة
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
    
    // MARK: - Initialization
    private init() {
        loadBlocks()
        updateActiveBlocks()
        updateUpcomingBlocks()
        
        // تحديث دوري كل دقيقة
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkAndActivateBlocks()
            self?.updateUpcomingBlocks()
        }
    }
    
    // MARK: - Public Methods
    
    /// إضافة حظر جديد
    func addBlock(_ configuration: BlockConfiguration) {
        let block = SavedBlock(
            id: UUID(),
            configuration: configuration,
            isActive: false,
            createdAt: Date()
        )
        
        blocks.append(block)
        saveBlocks()
        
        // تفعيل الحظر إذا كان الوقت الحالي ضمن نطاقه
        if shouldActivateNow(block) {
            activateBlock(block)
        }
        
        updateUpcomingBlocks()
        
        print("✅ Block added: \(configuration.name)")
    }
    
    /// تفعيل حظر معين
    func activateBlock(_ block: SavedBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        let config = block.configuration
        
        if config.type == .schedule {
            applyScheduleBlock(config)
        } else {
            applyTimerBlock(config)
        }
        
        // تحديث حالة الحظر
        blocks[index].isActive = true
        updateActiveBlocks()
        saveBlocks()
        
        print("✅ Block activated: \(config.name)")
    }
    
    /// إلغاء تفعيل حظر معين
    func deactivateBlock(_ block: SavedBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        // إزالة القيود
        shieldManager.removeAllRestrictions()
        
        // تحديث الحالة
        blocks[index].isActive = false
        updateActiveBlocks()
        saveBlocks()
        
        print("✅ Block deactivated: \(block.configuration.name)")
    }
    
    /// حذف حظر
    func deleteBlock(_ block: SavedBlock) {
        // إلغاء التفعيل أولاً إذا كان نشطاً
        if block.isActive {
            deactivateBlock(block)
        }
        
        // حذف من القائمة
        blocks.removeAll { $0.id == block.id }
        saveBlocks()
        updateUpcomingBlocks()
        
        print("✅ Block deleted: \(block.configuration.name)")
    }
    
    /// تعديل حظر
    func updateBlock(_ block: SavedBlock, with newConfiguration: BlockConfiguration) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else {
            print("❌ Block not found")
            return
        }
        
        // إلغاء الحظر القديم إذا كان نشطاً
        if blocks[index].isActive {
            deactivateBlock(block)
        }
        
        // تحديث الإعدادات
        blocks[index].configuration = newConfiguration
        
        // إعادة التفعيل إذا كان يجب أن يكون نشطاً
        if shouldActivateNow(blocks[index]) {
            activateBlock(blocks[index])
        }
        
        saveBlocks()
        updateUpcomingBlocks()
        
        print("✅ Block updated: \(newConfiguration.name)")
    }
    
    /// الحصول على جميع الكتل النشطة
    func getActiveBlocks() -> [SavedBlock] {
        return blocks.filter { $0.isActive }
    }
    
    /// الحصول على كتل Schedule فقط
    func getScheduleBlocks() -> [SavedBlock] {
        return blocks.filter { $0.configuration.type == .schedule }
    }
    
    /// الحصول على كتل Timer فقط
    func getTimerBlocks() -> [SavedBlock] {
        return blocks.filter { $0.configuration.type == .timer }
    }
    
    // MARK: - Private Methods
    
    /// تطبيق Schedule Block
    private func applyScheduleBlock(_ config: BlockConfiguration) {
        // تحويل الوقت إلى 24 ساعة
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        let endHour = convertTo24Hour(hour: config.toHour, period: config.toPeriod)
        
        // تطبيق الجدولة
        shieldManager.applyScheduledBlock(
            selection: config.selectedApps,
            schedule: .custom,
            startHour: startHour,
            startMinute: config.fromMinute,
            endHour: endHour,
            endMinute: config.toMinute
        )
    }
    
    /// تطبيق Timer Block
    private func applyTimerBlock(_ config: BlockConfiguration) {
        shieldManager.applyTimerBlock(
            selection: config.selectedApps,
            duration: .custom,
            customMinutes: config.durationMinutes
        )
    }
    
    /// التحقق من ضرورة تفعيل الحظر الآن
    private func shouldActivateNow(_ block: SavedBlock) -> Bool {
        let config = block.configuration
        
        if config.type == .schedule {
            return isWithinScheduleTime(config)
        }
        
        // Timer blocks تُفعل يدوياً فقط
        return false
    }
    
    /// التحقق من أن الوقت الحالي ضمن نطاق الجدولة
    private func isWithinScheduleTime(_ config: BlockConfiguration) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // التحقق من اليوم
        let currentWeekday = calendar.component(.weekday, from: now)
        let weekdayMapping: [Int: Weekday] = [
            2: .m, 3: .t, 4: .w, 5: .th, 6: .f, 7: .s, 1: .su
        ]
        
        guard let currentDay = weekdayMapping[currentWeekday],
              config.selectedDays.contains(currentDay) else {
            return false
        }
        
        // التحقق من الوقت
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentMinutes = currentHour * 60 + currentMinute
        
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        let endHour = convertTo24Hour(hour: config.toHour, period: config.toPeriod)
        
        let startMinutes = startHour * 60 + config.fromMinute
        let endMinutes = endHour * 60 + config.toMinute
        
        // حالة عادية (لا يعبر منتصف الليل)
        if startMinutes < endMinutes {
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        }
        // يعبر منتصف الليل
        else {
            return currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
    }
    
    /// تحويل الوقت من 12 ساعة إلى 24 ساعة
    private func convertTo24Hour(hour: Int, period: Period) -> Int {
        if period == .am {
            return hour == 12 ? 0 : hour
        } else {
            return hour == 12 ? 12 : hour + 12
        }
    }
    
    /// فحص وتفعيل الكتل التي يجب أن تكون نشطة
    private func checkAndActivateBlocks() {
        for block in blocks {
            if !block.isActive && shouldActivateNow(block) {
                activateBlock(block)
            } else if block.isActive && !shouldActivateNow(block) && block.configuration.type == .schedule {
                deactivateBlock(block)
            }
        }
    }
    
    /// تحديث قائمة الكتل النشطة
    private func updateActiveBlocks() {
        activeBlocks = blocks.filter { $0.isActive }
    }
    
    /// تحديث قائمة الكتل القادمة
    private func updateUpcomingBlocks() {
        var upcoming: [UpcomingBlock] = []
        let calendar = Calendar.current
        let now = Date()
        
        for block in blocks.filter({ $0.configuration.type == .schedule }) {
            let config = block.configuration
            
            // حساب الوقت التالي للحظر
            if let nextTime = getNextBlockTime(config, from: now) {
                let timeInterval = nextTime.timeIntervalSince(now)
                let minutes = Int(timeInterval / 60)
                
                if minutes > 0 && minutes < 1440 { // خلال 24 ساعة القادمة
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
        
        // ترتيب حسب الوقت المتبقي
        upcomingBlocks = upcoming.sorted {
            Int($0.timeRemaining) ?? 0 < Int($1.timeRemaining) ?? 0
        }
    }
    
    /// حساب الوقت التالي للحظر
    private func getNextBlockTime(_ config: BlockConfiguration, from date: Date) -> Date? {
        let calendar = Calendar.current
        let startHour = convertTo24Hour(hour: config.fromHour, period: config.fromPeriod)
        
        // جرب اليوم الحالي أولاً
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = startHour
        components.minute = config.fromMinute
        
        if let nextTime = calendar.date(from: components), nextTime > date {
            return nextTime
        }
        
        // جرب الأيام القادمة
        for dayOffset in 1...7 {
            if let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                components = calendar.dateComponents([.year, .month, .day], from: futureDate)
                components.hour = startHour
                components.minute = config.fromMinute
                
                if let nextTime = calendar.date(from: components) {
                    let weekday = calendar.component(.weekday, from: nextTime)
                    let weekdayMapping: [Int: Weekday] = [
                        2: .m, 3: .t, 4: .w, 5: .th, 6: .f, 7: .s, 1: .su
                    ]
                    
                    if let day = weekdayMapping[weekday], config.selectedDays.contains(day) {
                        return nextTime
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Persistence
    
    /// حفظ الكتل في UserDefaults
    private func saveBlocks() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(blocks)
            userDefaults.set(data, forKey: blocksKey)
            print("✅ Blocks saved successfully")
        } catch {
            print("❌ Failed to save blocks: \(error.localizedDescription)")
        }
    }
    
    /// تحميل الكتل من UserDefaults
    private func loadBlocks() {
        guard let data = userDefaults.data(forKey: blocksKey) else {
            print("ℹ️ No saved blocks found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            blocks = try decoder.decode([SavedBlock].self, from: data)
            print("✅ Blocks loaded successfully: \(blocks.count) blocks")
        } catch {
            print("❌ Failed to load blocks: \(error.localizedDescription)")
        }
    }
    
    /// مسح جميع الكتل
    func clearAllBlocks() {
        // إلغاء تفعيل جميع الكتل النشطة
        for block in activeBlocks {
            deactivateBlock(block)
        }
        
        // حذف الكتل
        blocks.removeAll()
        saveBlocks()
        updateUpcomingBlocks()
        
        print("✅ All blocks cleared")
    }
    
    // MARK: - Quick Actions
    
    /// إنشاء حظر ليلي سريع
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
            selectedDays: Set(Weekday.allCases),
            durationMinutes: 0,
            selectedApps: apps,
            brakeType: .takeItEasy
        )
        addBlock(config)
    }
    
    /// إنشاء مؤقت تركيز سريع
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
    
    /// إنشاء حظر نهاية الأسبوع
    func createWeekendBlock(apps: FamilyActivitySelection) {
        let config = BlockConfiguration(
            name: "Weekend Detox",
            type: .schedule,
            fromHour: 12,
            fromMinute: 0,
            fromPeriod: .am,
            toHour: 11,
            toMinute: 59,
            toPeriod: .pm,
            selectedDays: [.s, .su],
            durationMinutes: 0,
            selectedApps: apps,
            brakeType: .hardcore
        )
        addBlock(config)
    }
    
    // MARK: - Statistics
    
    /// الحصول على إحصائيات الاستخدام
    func getStatistics() -> BlockStatistics {
        let totalBlocks = blocks.count
        let activeCount = activeBlocks.count
        let scheduleCount = blocks.filter { $0.configuration.type == .schedule }.count
        let timerCount = blocks.filter { $0.configuration.type == .timer }.count
        
        return BlockStatistics(
            totalBlocks: totalBlocks,
            activeBlocks: activeCount,
            scheduleBlocks: scheduleCount,
            timerBlocks: timerCount
        )
    }
}

// MARK: - Supporting Models

/// إحصائيات الكتل
struct BlockStatistics {
    let totalBlocks: Int
    let activeBlocks: Int
    let scheduleBlocks: Int
    let timerBlocks: Int
}

/// حظر محفوظ
struct SavedBlock: Identifiable, Codable {
    let id: UUID
    var configuration: BlockConfiguration
    var isActive: Bool
    let createdAt: Date
}

// MARK: - Extensions for Codable Support

extension BlockConfiguration {
    enum CodingKeys: String, CodingKey {
        case name, type, fromHour, fromMinute, fromPeriod
        case toHour, toMinute, toPeriod, selectedDays
        case durationMinutes, brakeType
        case appTokensCount, categoryTokensCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type == .schedule ? "schedule" : "timer", forKey: .type)
        try container.encode(fromHour, forKey: .fromHour)
        try container.encode(fromMinute, forKey: .fromMinute)
        try container.encode(fromPeriod.rawValue, forKey: .fromPeriod)
        try container.encode(toHour, forKey: .toHour)
        try container.encode(toMinute, forKey: .toMinute)
        try container.encode(toPeriod.rawValue, forKey: .toPeriod)
        try container.encode(Array(selectedDays).map { $0.rawValue }, forKey: .selectedDays)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(brakeType.rawValue, forKey: .brakeType)
        try container.encode(selectedApps.applicationTokens.count, forKey: .appTokensCount)
        try container.encode(selectedApps.categoryTokens.count, forKey: .categoryTokensCount)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        
        let typeString = try container.decode(String.self, forKey: .type)
        type = typeString == "schedule" ? .schedule : .timer
        
        fromHour = try container.decode(Int.self, forKey: .fromHour)
        fromMinute = try container.decode(Int.self, forKey: .fromMinute)
        
        let fromPeriodString = try container.decode(String.self, forKey: .fromPeriod)
        fromPeriod = fromPeriodString == "AM" ? .am : .pm
        
        toHour = try container.decode(Int.self, forKey: .toHour)
        toMinute = try container.decode(Int.self, forKey: .toMinute)
        
        let toPeriodString = try container.decode(String.self, forKey: .toPeriod)
        toPeriod = toPeriodString == "AM" ? .am : .pm
        
        let daysArray = try container.decode([String].self, forKey: .selectedDays)
        selectedDays = Set(daysArray.compactMap { Weekday(rawValue: $0) })
        
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        
        let brakeTypeString = try container.decode(String.self, forKey: .brakeType)
        brakeType = BrakeType(rawValue: brakeTypeString) ?? .takeItEasy
        
        // ملاحظة: FamilyActivitySelection لا يمكن حفظه/تحميله مباشرة
        // يجب إعادة اختيار التطبيقات عند تحميل الحظر
        selectedApps = FamilyActivitySelection()
    }
}

// MARK: - Usage Examples in Comments

/*
 مثال الاستخدام:
 
 // الحصول على المدير
 let blockManager = BlockManager.shared
 
 // إضافة حظر جديد
 blockManager.addBlock(configuration)
 
 // تفعيل حظر
 blockManager.activateBlock(block)
 
 // إلغاء تفعيل حظر
 blockManager.deactivateBlock(block)
 
 // حذف حظر
 blockManager.deleteBlock(block)
 
 // الحصول على الكتل النشطة
 let activeBlocks = blockManager.activeBlocks
 
 // الحصول على الكتل القادمة
 let upcomingBlocks = blockManager.upcomingBlocks
 
 // إنشاء حظر ليلي سريع
 blockManager.createQuickNightBlock(apps: selection)
 
 // إنشاء مؤقت تركيز
 blockManager.createQuickFocusTimer(apps: selection, minutes: 60)
 
 // الحصول على الإحصائيات
 let stats = blockManager.getStatistics()
 print("Total: \(stats.totalBlocks)")
 print("Active: \(stats.activeBlocks)")
 */

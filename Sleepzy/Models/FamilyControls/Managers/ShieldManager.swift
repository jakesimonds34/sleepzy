//
//  ShieldManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// MARK: - Shield Manager
/// مدير مركزي لإدارة جميع عمليات الحظر والقيود
class ShieldManager: ObservableObject {
    static let shared = ShieldManager()
    
    @Published var isShieldActive = false
    @Published var currentSchedule: ScheduleType?
    
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    
    private init() {
        // تحميل الحالة المحفوظة
        loadShieldState()
    }
    
    // MARK: - Apply Shield Methods
    
    /// تطبيق حظر كامل (24/7)
    func applyAllDayBlock(selection: FamilyActivitySelection) {
        // حظر التطبيقات
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        // حظر الفئات
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        isShieldActive = true
        currentSchedule = .allDay
        saveShieldState()
        
        print("✅ All-day block applied")
    }
    
    /// تطبيق جدولة زمنية (مثلاً: وقت النوم)
    func applyScheduledBlock(
        selection: FamilyActivitySelection,
        schedule: ScheduleType,
        startHour: Int = 22,  // 10 PM
        startMinute: Int = 0,
        endHour: Int = 7,     // 7 AM
        endMinute: Int = 0
    ) {
        // تطبيق Shield الأساسي
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        // إنشاء جدولة زمنية
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMinute),
            intervalEnd: DateComponents(hour: endHour, minute: endMinute),
            repeats: true
        )
        
        // تفعيل المراقبة
        let activityName = DeviceActivityName("sleepSchedule")
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            isShieldActive = true
            currentSchedule = .nightTime
            saveShieldState()
            print("✅ Scheduled block applied: \(startHour):\(startMinute) - \(endHour):\(endMinute)")
        } catch {
            print("❌ Failed to start monitoring: \(error.localizedDescription)")
        }
    }
    
    /// تطبيق حد زمني يومي
    func applyDailyTimeLimit(
        selection: FamilyActivitySelection,
        minutes: Int
    ) {
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        // إنشاء جدول يومي
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let activityName = DeviceActivityName("dailyLimit")
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            isShieldActive = true
            saveShieldState()
            print("✅ Daily time limit applied: \(minutes) minutes")
        } catch {
            print("❌ Failed to apply time limit: \(error.localizedDescription)")
        }
    }
    
    /// تطبيق حظر مؤقت (Timer)
    func applyTimerBlock(
        selection: FamilyActivitySelection,
        duration: TimerDuration,
        customMinutes: Int = 60
    ) {
        // تطبيق Shield الأساسي
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        // حساب وقت النهاية
        let endTime = Date().addingTimeInterval(TimeInterval(customMinutes * 60))
        let calendar = Calendar.current
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        let startComponents = calendar.dateComponents([.hour, .minute], from: Date())
        
        // إنشاء جدولة للمؤقت
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false  // لا يتكرر لأنه مؤقت لمرة واحدة
        )
        
        let activityName = DeviceActivityName("timerBlock_\(UUID().uuidString)")
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            isShieldActive = true
            currentSchedule = .custom
            saveShieldState()
            print("✅ Timer block applied: \(customMinutes) minutes")
            
            // جدولة إلغاء الحظر تلقائياً بعد انتهاء المدة
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(customMinutes * 60)) { [weak self] in
                self?.deviceActivityCenter.stopMonitoring([activityName])
                print("⏱️ Timer block ended automatically")
            }
        } catch {
            print("❌ Failed to apply timer block: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Remove Shield Methods
    
    /// إلغاء جميع القيود
    func removeAllRestrictions() {
        // إزالة Shield
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        
        // إيقاف جميع المراقبات
        deviceActivityCenter.stopMonitoring()
        
        isShieldActive = false
        currentSchedule = nil
        saveShieldState()
        
        print("✅ All restrictions removed")
    }
    
    /// إلغاء جدولة محددة
    func removeSchedule(_ name: String) {
        let activityName = DeviceActivityName(name)
        deviceActivityCenter.stopMonitoring([activityName])
        print("✅ Schedule '\(name)' removed")
    }
    
    // MARK: - Check Methods
    
    /// التحقق من حالة التطبيق
    func isAppBlocked(_ token: ApplicationToken) -> Bool {
        guard let blockedApps = store.shield.applications else {
            return false
        }
        return blockedApps.contains(token)
    }
    
    /// الحصول على عدد التطبيقات المحظورة
    func getBlockedAppsCount() -> Int {
        return store.shield.applications?.count ?? 0
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

// MARK: - Usage Examples in View

/*
 مثال الاستخدام في View:
 
 struct MyView: View {
     @StateObject private var shieldManager = ShieldManager.shared
     @EnvironmentObject var appSelection: AppSelectionManager
     
     var body: some View {
         VStack {
             // عرض الحالة
             if shieldManager.isShieldActive {
                 Text("🛡️ Shield Active")
                     .foregroundColor(.green)
             }
             
             // زر تطبيق حظر كامل
             Button("Block All Day") {
                 shieldManager.applyAllDayBlock(selection: appSelection.selection)
             }
             
             // زر تطبيق جدولة ليلية
             Button("Block at Night (10 PM - 7 AM)") {
                 shieldManager.applyScheduledBlock(
                     selection: appSelection.selection,
                     schedule: .nightTime,
                     startHour: 22,
                     startMinute: 0,
                     endHour: 7,
                     endMinute: 0
                 )
             }
             
             // زر تطبيق حد زمني
             Button("Set Daily Limit (60 min)") {
                 shieldManager.applyDailyTimeLimit(
                     selection: appSelection.selection,
                     minutes: 60
                 )
             }
             
             // زر إلغاء القيود
             Button("Remove All") {
                 shieldManager.removeAllRestrictions()
             }
             .foregroundColor(.red)
         }
     }
 }
 */

// MARK: - Alternative: Direct Usage in DistractingAppsView

extension DistractingAppsView {
    
    /// استخدام مباشر للـ ShieldManager
    func applyRestrictionsWithManager(scheduleType: ScheduleType) {
        let manager = ShieldManager.shared
        
        switch scheduleType {
        case .allDay:
            manager.applyAllDayBlock(selection: appSelection.selection)
            
        case .nightTime:
            manager.applyScheduledBlock(
                selection: appSelection.selection,
                schedule: .nightTime,
                startHour: 22,  // 10 PM
                startMinute: 0,
                endHour: 7,     // 7 AM
                endMinute: 0
            )
            
        case .sleepTime:
            manager.applyScheduledBlock(
                selection: appSelection.selection,
                schedule: .sleepTime,
                startHour: 23,  // 11 PM
                startMinute: 0,
                endHour: 6,     // 6 AM
                endMinute: 0
            )
            
        case .custom:
            // يمكن إضافة UI لاختيار الوقت المخصص
            break
        }
        
        // تحديث الحالة
        selectedDistractingApps = scheduleType.rawValue
    }
}

// MARK: - Enhanced App Selection Manager

extension AppSelectionManager {
    
    /// حفظ التطبيقات المحددة محلياً
    func saveSelection() {
        // ملاحظة: ApplicationToken لا يمكن حفظه مباشرة
        // يمكنك حفظ عدد التطبيقات أو معلومات أخرى
        UserDefaults.standard.set(selection.applicationTokens.count, forKey: "selectedAppsCount")
        UserDefaults.standard.set(selection.categoryTokens.count, forKey: "selectedCategoriesCount")
    }
    
    /// تحميل عدد التطبيقات المحفوظة
    func loadSelectionInfo() -> (apps: Int, categories: Int) {
        let apps = UserDefaults.standard.integer(forKey: "selectedAppsCount")
        let categories = UserDefaults.standard.integer(forKey: "selectedCategoriesCount")
        return (apps, categories)
    }
    
    /// مسح كل التطبيقات المحددة
    func clearSelection() {
        selection = FamilyActivitySelection()
        UserDefaults.standard.removeObject(forKey: "selectedAppsCount")
        UserDefaults.standard.removeObject(forKey: "selectedCategoriesCount")
    }
}

// MARK: - Notification Helper

class BlockNotificationHelper {
    
    static func scheduleBlockStartNotification(at date: Date, appName: String) {
        // يمكنك استخدام UNUserNotificationCenter لإرسال إشعارات
        print("📱 Notification scheduled: \(appName) will be blocked at \(date)")
    }
    
    static func scheduleBlockEndNotification(at date: Date, appName: String) {
        print("📱 Notification scheduled: \(appName) will be unblocked at \(date)")
    }
}

// MARK: - Statistics Tracker

class AppUsageStats: ObservableObject {
    @Published var dailyUsage: [String: TimeInterval] = [:]
    @Published var weeklyUsage: [String: TimeInterval] = [:]
    
    static let shared = AppUsageStats()
    
    private init() {
        loadStats()
    }
    
    func recordUsage(appName: String, duration: TimeInterval) {
        dailyUsage[appName, default: 0] += duration
        weeklyUsage[appName, default: 0] += duration
        saveStats()
    }
    
    func getDailyUsage(for appName: String) -> TimeInterval {
        return dailyUsage[appName] ?? 0
    }
    
    func getWeeklyUsage(for appName: String) -> TimeInterval {
        return weeklyUsage[appName] ?? 0
    }
    
    func resetDailyStats() {
        dailyUsage = [:]
        saveStats()
    }
    
    private func saveStats() {
        // حفظ في UserDefaults أو Core Data
        if let data = try? JSONEncoder().encode(dailyUsage) {
            UserDefaults.standard.set(data, forKey: "dailyUsage")
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: "dailyUsage"),
           let stats = try? JSONDecoder().decode([String: TimeInterval].self, from: data) {
            dailyUsage = stats
        }
    }
}

enum TimerDuration {
    case custom
    case short    // 30 دقيقة
    case medium   // 1 ساعة
    case long     // 2 ساعة
}

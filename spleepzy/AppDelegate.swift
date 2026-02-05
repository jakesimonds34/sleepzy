//
//  AppDelegate.swift
//  GBV
//
//  Created by Khaled on 13/08/2024.
//

import UIKit
import NoorFont
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // MARK: - Appearance
        Appearance.configure()
        FontName.registerFonts()
        
        
        // تسجيل مهمة الخلفية
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.moneeb.Masjid.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // طلب إذن الإشعارات
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("🔔 Notification Permission: \(granted)")
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("🔧 Notification status: \(settings.authorizationStatus.rawValue)")
        }
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // تنفيذ المهمة في الخلفية
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleNextRefresh() // مهم جدًا
        PrayerScheduler.shared.scheduleForToday()
        task.setTaskCompleted(success: true)
    }
    
    // جدولة المهمة لليوم التالي
    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.moneeb.Masjid.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Failed to schedule BGTask: \(error)")
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PrayerScheduler.shared.scheduleForToday()
        completionHandler(.newData)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("🔔 Notification permission granted:", granted)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let name = notification.request.content.title
            .replacingOccurrences(of: "It's time for ", with: "")

        let mode = NotificationPreferences.shared.mode(for: name)

        if mode == .sound {
            FullAdhanPlayer.shared.play()
        }

        // لا نعرض الإشعار لأن التطبيق مفتوح
        completionHandler([])
    }
}

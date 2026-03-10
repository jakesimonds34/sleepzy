//
//  AppDelegate.swift
//  Sleepzy
//

import UIKit
import SuperwallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // MARK: - Superwall
        SuperwallService.configure()

        // MARK: - Appearance
        Appearance.configure()

        UNUserNotificationCenter.current().delegate = AlarmManager.shared
        AlarmManager.shared.setupNotificationCategories()
        AlarmManager.shared.requestNotificationPermission()

        return true
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}

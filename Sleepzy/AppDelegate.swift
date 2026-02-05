//
//  AppDelegate.swift
//  GBV
//
//  Created by Khaled on 13/08/2024.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // MARK: - Appearance
        Appearance.configure()
        
        return true
    }
}

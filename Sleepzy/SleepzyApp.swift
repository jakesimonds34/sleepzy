//
//  SleepzyApp.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

@main
struct SleepzyApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
//    @StateObject private var authManager = ScreenTimeAuthorizationManager()
//    @StateObject private var selectionManager = AppSelectionManager()
//    @StateObject private var shieldManager = ShieldManager.shared
//    @StateObject private var blockManager = BlockManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environmentObject(authManager)
//                .environmentObject(selectionManager)
//                .environmentObject(shieldManager)
//                .environmentObject(blockManager)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        print("Active")
                    case .inactive:
                        print("Inactive")
                    case .background:
                        print("Background")
                        // Settings.shared.save()
                    @unknown default:
                        print("@unknown default")
                    }
                }
        }
    }
}

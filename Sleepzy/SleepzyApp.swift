//
//  SleepzyApp.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

@main
struct SleepzyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        print("Active")
                        // ✅ أضف هذا فقط
                        Task { @MainActor in
                            BlockStore.shared.evaluateAllBlocks()
                        }
                    case .inactive:
                        print("Inactive")
                    case .background:
                        print("Background")
                    @unknown default:
                        print("@unknown default")
                    }
                }
        }
    }
}

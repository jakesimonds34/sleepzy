//
//  AppEnvironment.swift
//  DiwanV2
//
//  Created by Saadi Dalloul on 06/06/2024.
//  Copyright © 2024 Saadi Dalloul. All rights reserved.
//

import SwiftUI
import Combine   // ← ضروري في Xcode 26

@MainActor
final class AppEnvironment: ObservableObject {

    enum Status {
        case loading
        case onboarding
        case home
        case resetPassword
    }
    
    // https://rekerrsive.medium.com/three-ways-to-pop-to-the-root-view-in-a-swiftui-navigationview-430aee720c9a
    @Published var rootViewId = UUID()
    @Published var appStatus: Status = .loading
    
    // https://www.youtube.com/watch?v=cbJuWtGOjs4 please follow this link for enum inspiration
    @Published var locale = Language.current.locale
    @Published var layoutDirection = Language.current.layoutDirection
    @Published var colorScheme: ColorScheme?

    static let shared = AppEnvironment()
 
    // MARK: - Behaviour
    func setLanguage(_ newLanguage: Language) {
        Language.current = newLanguage
        locale = Language.current.locale
        layoutDirection = Language.current.layoutDirection
        // Self.shared.settings = nil || AppSettings.shared = nil // implement settings refresh
        reopenRootView()
    }

    func reopenRootView() {
        rootViewId = UUID()
    }
}

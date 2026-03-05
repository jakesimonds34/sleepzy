//
//  ContentView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @ObservedObject var appEnv = AppEnvironment.shared
    
    @State var currentStep: Double = 9
    @State var selectedDistractingApps: String? = ""
    
    // MARK: - Body
    var body: some View {
        content
            .buttonStyle(.plain)
            .preferredColorScheme(appEnv.colorScheme)
            .animation(.default, value: appEnv.appStatus)
            .environmentObject(appEnv)
            .environment(\.locale, appEnv.locale)
            .environment(\.layoutDirection, appEnv.layoutDirection)
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
    }
    
    private func handleDeepLink(url: URL) {
        let urlString = url.absoluteString
        if urlString.contains("type=recovery") {
            appEnv.appStatus = .resetPassword
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        switch appEnv.appStatus {
        case .loading:
            SplashView()
        case .resetPassword:
            NewPasswordView()
        case .onboarding:
            OnboardingView()
        case .home:
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}

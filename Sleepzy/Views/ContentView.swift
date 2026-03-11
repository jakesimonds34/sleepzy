//
//  ContentView.swift
//  Sleepzy
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appEnv = AppEnvironment.shared

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
        if url.absoluteString.contains("type=recovery") {
            appEnv.appStatus = .resetPassword
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appEnv.appStatus {
        case .loading:
            SplashView()
        case .resetPassword:
            NewPasswordView()
        case .onboarding:
            SplashView()
        case .home:
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}

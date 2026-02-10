//
//  ContentView.swift
//  Spleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @ObservedObject var appEnv = AppEnvironment.shared
    
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
        if appEnv.appStatus == .loading {
            SplashView()
        } else if appEnv.appStatus == .resetPassword {
            NewPasswordView()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}

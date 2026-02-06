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
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        if appEnv.appStatus == .loading {
            LoginView()
            
        } else if appEnv.appStatus == .onboarding {
            
            
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}

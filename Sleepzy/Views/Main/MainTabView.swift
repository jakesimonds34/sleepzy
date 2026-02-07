//
//  MainTabView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

import SwiftUI

struct MainTabView: View {

    // MARK: - Properties
    @EnvironmentObject var appEnv: AppEnvironment
    @State private var selection: Taps = .home
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.stackedLayoutAppearance.normal.iconColor = .green
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.green
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .red
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.red
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Body
    var body: some View {
        TabView(selection: $selection) {

            NavigationStack {
                HomeView(selection: $selection)
            }
            .tabItem {
                tabItem(for: .home)
            }
            .tag(Taps.home)

            NavigationStack {
                SoundsView(selection: $selection)
            }
            .tabItem {
                tabItem(for: .sounds)
            }
            .tag(Taps.sounds)

            NavigationStack {
                SleepLogView(selection: $selection)
            }
            .tabItem {
                tabItem(for: .sleepLog)
            }
            .tag(Taps.sleepLog)

            NavigationStack {
                AlarmsView(selection: $selection)
            }
            .tabItem {
                tabItem(for: .alarm)
            }
            .tag(Taps.alarm)

            NavigationStack {
                SettingsView(selection: $selection)
            }
            .tabItem {
                tabItem(for: .settings)
            }
            .tag(Taps.settings)
        }
        .id(appEnv.rootViewId)
        .background(Color.white.ignoresSafeArea())
        .safeTabBarMinimize()
    }
}

// MARK: - Tabs Enum
enum Taps: Hashable {
    case home
    case sounds
    case sleepLog
    case alarm
    case settings
}

// MARK: - Tab Item UI
extension MainTabView {

    @ViewBuilder
    private func tabItem(for tab: Taps) -> some View {
        tabView(
            for: tab,
            image: image(for: tab),
            title: title(for: tab)
        )
    }

    private func tabView(for tab: Taps,
                         image: ImageResource,
                         title: String) -> some View {
        VStack(spacing: 4) {
            MyImage(source: .asset(image, renderingMode: .template))
            Text(title)
        }
        .foregroundStyle(selection == tab ? Color.red : Color.green)
    }

    private func image(for tab: Taps) -> ImageResource {
        switch tab {
        case .home: return .tabHome
        case .sounds: return .tabSounds
        case .sleepLog: return .tabSleepLog
        case .alarm: return .tabAlarms
        case .settings: return .tabSettings
        }
    }

    private func title(for tab: Taps) -> String {
        switch tab {
        case .home: return "Home"
        case .sounds: return "Sounds"
        case .sleepLog: return "Sleep Log"
        case .alarm: return "Alarms"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppEnvironment.shared)
}

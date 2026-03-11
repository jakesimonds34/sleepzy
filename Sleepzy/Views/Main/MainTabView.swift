//
//  MainTabView.swift
//  Sleepzy
//

import SwiftUI
import SuperwallKit

struct MainTabView: View {

    @EnvironmentObject var appEnv: AppEnvironment
    @State private var selection: Taps = .home
    @State private var didCheckSubscription = false

    init() {
        self.selection = Taps.home
    }

    var body: some View {
        TabView(selection: $selection) {

            NavigationStack {
                HomeView()
            }
            .tabItem { tabItem(for: .home) }
            .tag(Taps.home)

            NavigationStack {
                SleepSoundsView(selection: $selection)
            }
            .tabItem { tabItem(for: .sounds) }
            .tag(Taps.sounds)

            NavigationStack {
                SleepLogView(selection: $selection)
            }
            .tabItem { tabItem(for: .sleepLog) }
            .tag(Taps.sleepLog)

            NavigationStack {
                AlarmsView(selection: $selection)
            }
            .tabItem { tabItem(for: .alarm) }
            .tag(Taps.alarm)

            NavigationStack {
                SettingsView(selection: $selection)
            }
            .tabItem { tabItem(for: .settings) }
            .tag(Taps.settings)
        }
        .accentColor(.white)
        .alarmRingingOverlay()
        .id(appEnv.rootViewId)
        .background(Color.white.ignoresSafeArea())
        .safeTabBarMinimize()
        // ✅ تحقق من الاشتراك عند فتح MainTabView لأول مرة فقط
        .task {
            guard !didCheckSubscription else { return }
            didCheckSubscription = true

            let status = Superwall.shared.subscriptionStatus
            if case .active = status { return }

            SuperwallService.presentPaywall(onPurchase: {
                // المستخدم اشترك — يبقى في MainTabView
            })
        }
    }
}

// MARK: - Tabs Enum
enum Taps: Hashable {
    case home, sounds, sleepLog, alarm, settings
}

// MARK: - Tab Item UI
extension MainTabView {

    @ViewBuilder
    private func tabItem(for tab: Taps) -> some View {
        tabView(for: tab, image: image(for: tab), title: title(for: tab))
    }

    private func tabView(for tab: Taps, image: ImageResource, title: String) -> some View {
        VStack(spacing: 4) {
            MyImage(source: .asset(image, renderingMode: .template))
            Text(title)
        }
    }

    private func image(for tab: Taps) -> ImageResource {
        switch tab {
        case .home:     return selection == tab ? .tabHomeSelected     : .tabHome
        case .sounds:   return selection == tab ? .tabSoundsSelected   : .tabSounds
        case .sleepLog: return selection == tab ? .tabSleepLogSelected : .tabSleepLog
        case .alarm:    return selection == tab ? .tabAlarmsSelected   : .tabAlarms
        case .settings: return selection == tab ? .tabSettingsSelected : .tabSettings
        }
    }

    private func title(for tab: Taps) -> String {
        switch tab {
        case .home:     return "Home"
        case .sounds:   return "Sounds"
        case .sleepLog: return "Sleep Log"
        case .alarm:    return "Alarms"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppEnvironment.shared)
}

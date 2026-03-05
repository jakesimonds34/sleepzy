//
//  SettingsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI
import FamilyControls
import SwiftMessages

struct SettingsView: View {

    @StateObject private var profileStore = UserProfileStore.shared
    @StateObject private var blockStore   = BlockStore.shared
    @StateObject private var viewModel    = AuthViewModel()
    @State private var showEditProfile          = false
    @State private var showShieldAppPicker      = false
    @State private var showShieldSchedule       = false
    @State private var showSleepSchedule        = false
    @State private var showHelpSupport          = false
    @State private var showPrivacyPolicy        = false
    @State private var showLogoutConfirm        = false
    
    @Binding var selection: Taps

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                AppHeaderView(title: "Settings", subTitle: "", paddingTop: 0)
                    .padding(.horizontal)
                
                // ── Profile Card ──────────────────────────────
                profileCard
                    .padding(.horizontal, AppTheme.cardPadding)
                    .padding(.top, 25)
                    .padding(.bottom, 20)
                
                // ── DIGITAL SHIELD section ────────────────────
                settingsSection(title: "DIGITAL SHIELD") {
                    settingsRow(
                        icon: "app.badge.fill",
                        iconColor: AppTheme.accentBright,
                        title: appsBlockedTitle,
                        hasChevron: true
                    ) {
                        showShieldAppPicker = true
                    }
                }
                
                spacer24
                
                // ── DIGITAL SHIELD SCHEDULE section ──────────
                settingsSection(title: "DIGITAL SHIELD SCHEDULE") {
                    shieldScheduleRow
                }
                
                spacer24
                
                settingsSection(title: "SLEEP SCHEDULE") {
                    settingsRow(
                        icon: "moon.stars.fill",
                        iconColor: Color(hex: "7B8FF7"),
                        title: sleepScheduleTitle,
                        hasChevron: true
                    ) {
                        showSleepSchedule = true
                    }
                }
                
                spacer24
                
                // ── NOTIFICATION section ──────────────────────
                settingsSection(title: "NOTIFICATION") {

                    // ✅ Wind Down — مربوط بـ WindDownManager
                    toggleRow(
                        icon: "wind",
                        iconColor: Color(hex: "7B8FF7"),
                        title: "Wind down",
                        isOn: Binding(
                            get: { profileStore.profile.windDownNotification },
                            set: { enabled in
                                profileStore.profile.windDownNotification = enabled
                                profileStore.save()
                                Task {
                                    if enabled {
                                        let granted = await WindDownManager.shared.requestPermission()
                                        if granted {
                                            // اقرأ من WindDownManager UserDefaults مباشرة
                                            // يُحدَّث عند Save في SleepScheduleSheet
                                            let saved = UserDefaults.standard.double(forKey: "winddown.bedHour")
                                            let bed   = saved > 0 ? saved : (Settings.shared.currentUser?.bedHour ?? profileStore.profile.bedHour)
                                            print("🛏 winddown.bedHour (UserDefaults) = \(saved)")
                                            print("🛏 final bed = \(bed)")
                                            await WindDownManager.shared.scheduleFromBedHour(bed)
                                        }
                                    } else {
                                        WindDownManager.shared.cancel()
                                    }
                                }
                            }
                        )
                    )
                    
                    settingsDivider
                    
                    toggleRow(
                        icon: "checkmark.shield.fill",
                        iconColor: AppTheme.accentBright,
                        title: "Digital Shield",
                        isOn: Binding(
                            get: { profileStore.profile.shieldNotification },
                            set: { enabled in
                                profileStore.profile.shieldNotification = enabled
                                profileStore.save()
                                Task {
                                    if enabled {
                                        let granted = await DigitalShieldNotificationManager.shared.requestPermission()
                                        if granted,
                                           let startTime = BlockStore.shared.digitalShield?.startTime {
                                            await DigitalShieldNotificationManager.shared.scheduleAll(startTime: startTime)
                                        }
                                    } else {
                                        DigitalShieldNotificationManager.shared.cancel()
                                    }
                                }
                            }
                        )
                    )
                }
                
                spacer24
                
                // ── DATA SYNC section ─────────────────────────
                settingsSection(title: "DATA SYNC") {
                    toggleRow(
                        icon: "heart.fill",
                        iconColor: Color.red,
                        title: "Apple Health",
                        isOn: Binding(
                            get: { profileStore.profile.appleHealthSync },
                            set: { enabled in
                                profileStore.profile.appleHealthSync = enabled
                                profileStore.save()
                                Task {
                                    if enabled {
                                        // طلب صلاحية HealthKit + جلب البيانات
                                        await HealthKitManager.shared.requestAuthorization()
                                        if HealthKitManager.shared.isAuthorized {
                                            await HealthKitManager.shared.fetchSleepData(for: .weekly)
                                        }
                                    } else {
                                        // مسح البيانات المحلية عند الإيقاف
                                        HealthKitManager.shared.clearSessions()
                                    }
                                }
                            }
                        )
                    )
                }
                
                spacer24
                
                // ── Log out ───────────────────────────────────
                logoutButton
                    .padding(.horizontal, AppTheme.pagePadding)
                
                // ── Bottom links ──────────────────────────────
                VStack(spacing: 16) {
                    Button("Help and Support") { showHelpSupport = true }
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .underline()

                    Button("Privacy Policy") { showPrivacyPolicy = true }
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .underline()
                }
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(
            MyImage(source: .asset(.bgSounds))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        // ✅ إعادة جدولة Wind Down عند فتح الشاشة إذا كان مفعّلاً
        .task {
            if profileStore.profile.windDownNotification {
                let granted = await WindDownManager.shared.requestPermission()
                if granted {
                    await WindDownManager.shared.scheduleFromBedHour(profileStore.profile.bedHour)
                }
            }
        }
        .sheet(isPresented: $showShieldAppPicker) {
            if var shield = blockStore.digitalShield {
                FamilyPickerSheet(
                    isPresented: $showShieldAppPicker,
                    selection: Binding(
                        get: { shield.appSelection },
                        set: { shield.appSelection = $0; blockStore.updateDigitalShield(shield) }
                    )
                )
            }
        }
        .sheet(isPresented: $showShieldSchedule) {
            DigitalShieldScheduleView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showSleepSchedule) {
            SleepScheduleSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showHelpSupport) {
            SafariSheet(url: URL(string: "https://app.termly.io/policy-viewer/policy.html?policyUUID=b18add3c-759c-4bc3-b343-b67ee81153cc")!)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariSheet(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
        .confirmationDialog("Log out", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                Task {
                    await AuthViewModel().signOut()
                    AppEnvironment.shared.appStatus = .loading
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.pillBackground)
                    .frame(width: 80, height: 80)
                Text(profileStore.profile.initials)
                    .font(.system(size: 33, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(profileStore.profile.fullName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            HStack(spacing: 4) {
                Text("Sleep Goal:")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                Text(profileStore.profile.sleepGoal)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            Button { showEditProfile = true } label: {
                Text("View Profile")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .underline()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                .stroke(AppTheme.separatorColor, lineWidth: 1)
        )
    }

    // MARK: - Shield Schedule Row

    private var shieldScheduleRow: some View {
        Button { showShieldSchedule = true } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    if let shield = blockStore.digitalShield {
                        Text("\(shield.displayStartTime) - \(shield.displayEndTime)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        HStack(spacing: 6) {
                            ForEach(RepeatDay.allCases, id: \.0.rawValue) { day, label in
                                let active = shield.repeatDays.contains(day)
                                Text(label)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
                                    .background(active ? AppTheme.accent : AppTheme.tagBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                    .overlay(RoundedCorner(radius: 8, corners: .allCorners).stroke(Color(hex: active ? "988AE1" : "FFFFFF").opacity(0.4), lineWidth: 0.5))
                            }
                        }
                    } else {
                        Text("Not configured")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Helpers

    private var appsBlockedTitle: String {
        guard let shield = blockStore.digitalShield else { return "No apps selected" }
        let count = shield.appSelection.applicationTokens.count + shield.appSelection.categoryTokens.count
        return count == 0 ? "Select apps to block" : "\(count) App\(count == 1 ? "" : "s") Blocked"
    }

    private var logoutButton: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            HStack(spacing: 10) {
                MyImage(source: .asset(.logOutIcon))
                    .scaledToFit()
                    .frame(width: 24)
                Text("Log out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "FF7694").opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                    .stroke(Color(hex: "D95B7A").opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var spacer24: some View { Color.clear.frame(height: 24) }

    private var settingsDivider: some View {
        Divider()
            .background(AppTheme.separatorColor)
            .padding(.leading, AppTheme.cardPadding + 28 + 12)
    }

    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .kerning(2.2)
                .padding(.horizontal, AppTheme.pagePadding)
            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.fieldRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.fieldRadius)
                    .stroke(AppTheme.separatorColor, lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.pagePadding)
        }
    }

    @ViewBuilder
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        hasChevron: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.itemSpacing)
            .frame(height: 52)
        }
    }

    @ViewBuilder
    private func toggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppTheme.toggleOnTint))
                .labelsHidden()
        }
        .padding(.horizontal, AppTheme.cardPadding)
        .frame(height: 52)
    }

    private var sleepScheduleTitle: String {
        let bed  = formatHour(profileStore.profile.bedHour)
        let wake = formatHour(profileStore.profile.wakeHour)
        return "\(bed)  →  \(wake)"
    }

    private func formatHour(_ hour: Double) -> String {
        let h = Int(hour) % 24
        let suffix = h >= 12 ? "PM" : "AM"
        let display = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return "\(display):00 \(suffix)"
    }
}

// MARK: - EditProfileView

struct EditProfileView: View {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var store = UserProfileStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var selectedGoal: String? = nil
    @State private var showGoalPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                Text(initials)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)

                        fieldSection(label: "FIRST NAME", placeholder: "Full name", text: $fullName)

                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel(text: "SLEEP GOAL")
                            Button { showGoalPicker = true } label: {
                                HStack {
                                    Text(selectedGoal ?? "Select a goal")
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedGoal == nil ? .white.opacity(0.4) : .white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                            }
                        }

                        Button {
                            guard !viewModel.isLoading, !fullName.isEmpty, selectedGoal != nil else { return }
                            Task { await save() }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Save Profile")
                            }
                        }
                        .style(.primary)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppTheme.pagePadding)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(AppTheme.accentBright)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showGoalPicker) {
                GoalPickerSheet(selectedGoal: $selectedGoal)
            }
        }
        .onAppear {
            fullName = store.profile.fullName
            selectedGoal = store.profile.sleepGoal
        }
    }

    private var initials: String {
        let parts = fullName.split(separator: " ")
        return (parts.first?.prefix(1).uppercased() ?? "") +
               (parts.dropFirst().last?.prefix(1).uppercased() ?? "")
    }

    @ViewBuilder
    private func fieldSection(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: label)
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(AppTheme.accentBright)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
        }
    }

    private func save() async {
        guard !fullName.isEmpty, let goal = selectedGoal else {
            Alerts.show(title: nil, body: "Please fill all fields", theme: .warning)
            return
        }
        await viewModel.updateProfile(fullName: fullName, goal: goal)
        let parts = fullName.split(separator: " ")
        store.profile.firstName = parts.first.map(String.init) ?? ""
        store.profile.lastName  = parts.dropFirst().joined(separator: " ")
        store.profile.sleepGoal = goal
        store.save()
        Alerts.show(title: nil, body: "Profile updated successfully", theme: .success)
        dismiss()
    }
}

// MARK: - GoalPickerSheet

struct GoalPickerSheet: View {
    @Binding var selectedGoal: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            OnboardingStepView(
                data: OnboardingStep.goal,
                selectedValue: $selectedGoal
            )
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("Sleep Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accentBright)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    SettingsView(selection: .constant(.settings))
}

// MARK: - SleepScheduleSheet + WindDown auto-reschedule
// ملاحظة: أضف هذا الكود داخل save button action في SleepScheduleSheet الموجود عندك:
//
//    Button {
//        guard !viewModel.isLoading else { return }
//        Task {
//            await viewModel.updateSleepSchedule(bedHour: bedHour, wakeHour: wakeHour)
//
//            // ✅ أعد جدولة Wind Down إذا كان مفعّلاً
//            if UserProfileStore.shared.profile.windDownNotification {
//                await WindDownManager.shared.scheduleFromProfile()
//            }
//
//            dismiss()
//        }
//    }

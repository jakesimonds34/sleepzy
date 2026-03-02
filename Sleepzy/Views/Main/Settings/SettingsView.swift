//
//  SettingsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

/*
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var selection: Taps
    
    @State private var notificationEnabled: Bool = true
    @State private var digitalShieldEnabled: Bool = true
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "Settings", subTitle: "", paddingTop: 0)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    //MARK: User Info
                    VStack(spacing: 11) {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 80)
                                .overlay {
                                    Text("JS")
                                        .font(.appBold32)
                                }
                            
                            Text("Jake Simonds")
                                .font(.appMedium24)
                            
                            HStack {
                                Text("Sleep Goal: ")
                                    .font(.appRegular16)
                                Text("Better Sleep")
                                    .font(.appMedium24)
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            Text("View Profile")
                                .underline()
                                .foregroundStyle(.white)
                                .font(.appMedium16)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.05))
                    .cornerRadius(16)
                    
                    //MARK: Digital Shield
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DiGITAL SHIELD")
                            .font(.appRegular14)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("13 Apps Blocked")
                                
                                Spacer()
                                MyImage(source: .system("chevron.right", renderingMode: .template))
                                    .frame(width: 6)
                            }
                            .roundedView()
                        }
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Schedule
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SCHEDULE")
                            .font(.appRegular14)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("10:00 PM to 08:00 AM")
                                
                                Spacer()
                                MyImage(source: .system("chevron.right", renderingMode: .template))
                                    .frame(width: 6)
                            }
                            .roundedView()
                        }
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Schedule
                    VStack(alignment: .leading, spacing: 0) {
                        Text("NOTIFICATION")
                            .font(.appRegular14)
                        
                        Toggle("Wind Down", isOn: $notificationEnabled)
                            .roundedView()
                        
                        Toggle("Digital Shield", isOn: $digitalShieldEnabled)
                            .roundedView()
                    }
                    .foregroundColor(.white)
                    
                    //MARK: DATA SYNC
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DATA SYNC")
                            .font(.appRegular14)
                        
                        Toggle("Apple Health", isOn: $notificationEnabled)
                            .roundedView()
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Log Out
                    Button {
                        AppEnvironment.shared.appStatus = .loading
                    } label: {
                        HStack {
                            MyImage(source: .asset(.logOutIcon))
                                .scaledToFit()
                                .frame(width: 24)
                            
                            Text("Log out")
                                .font(.appMedium18)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .frame(height: 54)
                        .padding(.horizontal)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FF7694").opacity(0.4),
                                    Color(hex: "#FF7694").opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .cornerRadius(8)
                    }
                    
                    VStack(spacing: 16) {
                        //MARK: Help and Support
                        Button {
                            
                        } label: {
                            Text("Help and Support")
                                .font(.appMedium16)
                                .underline()
                                .foregroundStyle(.white)
                        }
                        
                        //MARK: Help and Support
                        Button {
                            
                        } label: {
                            Text("Privacy Policy")
                                .font(.appMedium16)
                                .underline()
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SettingsView(selection: $selection)
}
*/

import SwiftUI
import FamilyControls

struct SettingsView: View {

    @StateObject private var profileStore = UserProfileStore.shared
    @StateObject private var blockStore   = BlockStore.shared
    @State private var showEditProfile          = false
    @State private var showShieldAppPicker      = false
    @State private var showShieldSchedule       = false
    
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
                    
                    // Row 1: Apps Blocked
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
                    
                    // Single row: time range + repeat days badge
                    shieldScheduleRow
                }
                
                spacer24
                
                // ── NOTIFICATION section ──────────────────────
                settingsSection(title: "NOTIFICATION") {
                    
                    toggleRow(
                        icon: "wind",
                        iconColor: Color(hex: "7B8FF7"),
                        title: "Wind down",
                        isOn: Binding(
                            get: { profileStore.profile.windDownNotification },
                            set: { profileStore.profile.windDownNotification = $0; profileStore.save() }
                        )
                    )
                    
                    settingsDivider
                    
                    toggleRow(
                        icon: "checkmark.shield.fill",
                        iconColor: AppTheme.accentBright,
                        title: "Digital Shield",
                        isOn: Binding(
                            get: { profileStore.profile.shieldNotification },
                            set: { profileStore.profile.shieldNotification = $0; profileStore.save() }
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
                            set: { profileStore.profile.appleHealthSync = $0; profileStore.save() }
                        )
                    )
                }
                
                spacer24
                
                // ── Log out ───────────────────────────────────
                logoutButton
                    .padding(.horizontal, AppTheme.pagePadding)
                
                // ── Bottom links ──────────────────────────────
                VStack(spacing: 16) {
                    Button("Help and Support") {}
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .underline()
                    
                    Button("Privacy Policy") {}
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
        // Shield App Picker
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
        // Shield Schedule editor
        .sheet(isPresented: $showShieldSchedule) {
            DigitalShieldScheduleView()
        }
        // Edit Profile
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 12) {

            // Avatar circle
            ZStack {
                Circle()
                    .fill(AppTheme.pillBackground)
                    .frame(width: 80, height: 80)
                Text(profileStore.profile.initials)
                    .font(.system(size: 33, weight: .bold))
                    .foregroundColor(.white)
            }

            // Name
            Text(profileStore.profile.fullName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            // Sleep goal
            HStack(spacing: 4) {
                Text("Sleep Goal:")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                Text(profileStore.profile.sleepGoal)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            // View Profile button
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

    // MARK: - Shield Schedule Row (custom — shows time + days)

    private var shieldScheduleRow: some View {
        Button { showShieldSchedule = true } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {

                    // Time range
                    if let shield = blockStore.digitalShield {
                        Text("\(shield.displayStartTime) - \(shield.displayEndTime)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        // Repeat days pills
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

    // MARK: - Apps blocked title helper

    private var appsBlockedTitle: String {
        guard let shield = blockStore.digitalShield else { return "No apps selected" }
        let count = shield.appSelection.applicationTokens.count + shield.appSelection.categoryTokens.count
        return count == 0 ? "Select apps to block" : "\(count) App\(count == 1 ? "" : "s") Blocked"
    }

    // MARK: - Log Out Button

    private var logoutButton: some View {
        Button {
            // handle logout
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("Log out")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, AppTheme.cardPadding)
            .foregroundStyle(.white)
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

    // MARK: - Reusable sub-components

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
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(iconColor)
                    .frame(width: 28)

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
}

// MARK: - EditProfileView

struct EditProfileView: View {
    @StateObject private var store = UserProfileStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var selectedGoal: String? = nil
    @State private var showGoalPicker = false  // ← جديد

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Avatar
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

                        // First Name
                        fieldSection(label: "FIRST NAME", placeholder: "Full name", text: $fullName)

                        // Sleep Goal ← نفس شكل fieldSection ولكن تفتح sheet
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

                        PrimaryButton(title: "Save Profile", action: save)
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
                        HStack(spacing: 4) { Image(systemName: "chevron.left"); Text("Back") }
                            .foregroundColor(AppTheme.accentBright)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            // ✅ Sheet الـ Goals
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
                .font(.system(size: 16)).foregroundColor(.white).tint(AppTheme.accentBright)
                .padding(.horizontal, 14).frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
        }
    }

    private func save() {
        let parts = fullName.split(separator: " ")
        let first = parts.first.map(String.init) ?? ""
        let last  = parts.dropFirst().joined(separator: " ")
        if !first.isEmpty { store.profile.firstName = first }
        if !last.isEmpty  { store.profile.lastName  = last }
        if let goal = selectedGoal { store.profile.sleepGoal = goal }
        store.save()
        dismiss()
    }
}

// MARK: - Goal Picker Sheet
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

//
//  HomeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @StateObject private var vm    = HomeViewModel()
    @StateObject private var store = BlockStore.shared
    @StateObject private var authManager = AuthorizationManager.shared

    @State private var showNewBlock        = false
    @State private var editingSchedule: ScheduleBlock? = nil
    @State private var editingTimer:    TimerBlock?    = nil
    @State private var showShieldAppPicker = false
    
    var body: some View {
        Group {
            if authManager.isAuthorized {
                ScrollView {
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .sheet(isPresented: $showNewBlock) { NewBlockView() }
                        .sheet(item: $editingSchedule) { block in
                            EditScheduleBlockView(block: block)
                        }
                        .sheet(item: $editingTimer) { block in
                            EditTimerBlockView(block: block)
                        }
                        .sheet(isPresented: $showShieldAppPicker) {
                            if var shield = store.digitalShield {
                                FamilyPickerSheet(
                                    isPresented: $showShieldAppPicker,
                                    selection: Binding(
                                        get: { shield.appSelection },
                                        set: { shield.appSelection = $0; store.updateDigitalShield(shield) }
                                    )
                                )
                            }
                        }
                        .onAppear { vm.refreshGreeting() }
                }
            } else {
                notAuthorized
            }
        }
        .background(
            MyImage(source: .asset(.bgHome))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .task {
            await authManager.requestAuthorization()
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection.padding(.top, 60)
            
            if let shield = store.digitalShield {
                digitalShieldCard(shield)
            }

            if !store.scheduleBlocks.isEmpty {
                sectionHeader("Scheduled")
                ForEach(store.scheduleBlocks) { block in
                    scheduleBlockRow(block)
                }
            }
            
            if !store.timerBlocks.isEmpty {
                sectionHeader("Timers")
                ForEach(store.timerBlocks) { block in
                    timerBlockRow(block)
                }
            }

            addLimitButton
            Spacer(minLength: 80)
        }
        .padding(.horizontal, AppTheme.pagePadding)
    }
    
    // MARK: - Not Authoried
    private var notAuthorized: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("TimeScreen")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Take control of your digital life.\nBlock distracting apps on your schedule.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            if let error = authManager.authError {
                Text(error.localizedDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            PrimaryButton(title: "Enable Screen Time") {
                Task { await authManager.requestAuthorization() }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vm.todayDateString)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
            Text(vm.timeOfDayGreeting)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(.white.opacity(0.7))
    }
    
    // MARK: - Digital Shield Card
    private func digitalShieldCard(_ shield: DigitalShield) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 12) {

                // Title + toggle
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.accentBright.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 42, height: 42)
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(AppTheme.accentBright)
                            .font(.system(size: 18))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(shield.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        if shield.minutesUntilStart > 0 {
                            Text("Starting in \(shield.minutesUntilStart) min")
                                .font(.system(size: 12))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(AppTheme.pillBackground)
                                .foregroundColor(.white.opacity(0.8))
                                .clipShape(Capsule())
                        } else {
                            Text("Active now")
                                .font(.system(size: 12))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.green.opacity(0.25))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { shield.isEnabled },
                        set: { _ in vm.toggleShield() }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.toggleOnTint))
                    .labelsHidden()
                }

                // Time range
                HStack(spacing: 10) {
                    Label(shield.displayStartTime, systemImage: "sunset")
                        .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10)).foregroundColor(AppTheme.textSecondary)
                    Label(shield.displayEndTime, systemImage: "sunrise")
                        .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                }

                Divider().background(AppTheme.separatorColor)

                // Apps + Manage button
                HStack {
                    if shield.appSelection.applicationTokens.isEmpty &&
                       shield.appSelection.categoryTokens.isEmpty {
                        Text("Tap Manage Apps to select apps")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    } else {
                        AppIconRowView(selection: shield.appSelection, maxVisible: 5)
                    }
                    Spacer()
                    Button { showShieldAppPicker = true } label: {
                        Text("Manage Apps")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            .padding(AppTheme.cardPadding)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                .stroke(AppTheme.separatorColor, lineWidth: 1))
        }
    }
    
    // MARK: - Schedule Block Row
    private func scheduleBlockRow(_ block: ScheduleBlock) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.accent.opacity(0.2))
                    .frame(width: 42, height: 42)
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppTheme.accentBright)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(block.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(block.displayFromTime) – \(block.displayToTime)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // ✏️ Edit button
            Button { editingSchedule = block } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.textSecondary)
            }

            // Toggle on/off
            Toggle("", isOn: Binding(
                get: { block.isEnabled },
                set: { _ in store.toggleScheduleBlock(id: block.id) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.toggleOnTint))
            .labelsHidden()
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius)
            .stroke(AppTheme.separatorColor, lineWidth: 1))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                store.removeScheduleBlock(id: block.id)
            } label: { Label("Delete", systemImage: "trash") }
        }
        .swipeActions(edge: .leading) {
            Button { editingSchedule = block } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppTheme.accent)
        }
    }
    
    // MARK: - Timer Block Row
    private func timerBlockRow(_ block: TimerBlock) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: "timer").foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(block.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(block.isRunning ? "Running – \(formatted(block))" : "\(block.durationMinutes) min")
                    .font(.system(size: 12))
                    .foregroundColor(block.isRunning ? .orange : AppTheme.textSecondary)
            }

            Spacer()

            Button {
                block.isRunning
                    ? store.stopTimerBlock(id: block.id)
                    : store.startTimerBlock(id: block.id)
            } label: {
                Image(systemName: block.isRunning ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(block.isRunning ? .red : AppTheme.accentBright)
            }

            // ✏️ Edit button
            Button { editingTimer = block } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius)
            .stroke(AppTheme.separatorColor, lineWidth: 1))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                store.removeTimerBlock(id: block.id)
            } label: { Label("Delete", systemImage: "trash") }
        }
        .swipeActions(edge: .leading) {
            Button { editingTimer = block } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppTheme.accent)
        }
    }

    private func formatted(_ block: TimerBlock) -> String {
        guard let s = block.remainingSeconds else { return "" }
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    // MARK: - Add Button
    private var addLimitButton: some View {
        Button { showNewBlock = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20)).foregroundColor(AppTheme.accentBright)
                Text("Limit App or Website")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(.white.opacity(0.2))
            )
        }
    }

    // MARK: - Sleep Bar
    private var sleepBar: some View {
        HStack {
            Image(systemName: "moon.zzz").foregroundColor(.white.opacity(0.5))
            Text("Sleep Last Night").font(.system(size: 14)).foregroundColor(.white.opacity(0.45))
            Spacer()
            HStack(spacing: 5) {
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text(store.sleepDuration)
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            }
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    HomeView()
}

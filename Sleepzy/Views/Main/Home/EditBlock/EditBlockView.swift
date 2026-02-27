import SwiftUI
import FamilyControls

// MARK: - EditScheduleBlockView

struct EditScheduleBlockView: View {

    let block: ScheduleBlock
    @StateObject private var store = BlockStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var name:           String                  = ""
    @State private var fromHour:       Int                     = 10
    @State private var fromMinute:     Int                     = 0
    @State private var fromPeriod:     String                  = "PM"
    @State private var toHour:         Int                     = 8
    @State private var toMinute:       Int                     = 0
    @State private var toPeriod:       String                  = "AM"
    @State private var repeatDays:     RepeatDay               = []
    @State private var appSelection:   FamilyActivitySelection = .init()
    @State private var brakeLevel:     BrakeLevel              = .easy
    @State private var showAppPicker   = false
    @State private var showBrakePicker = false
    @State private var showDeleteConfirm = false

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (!appSelection.applicationTokens.isEmpty || !appSelection.categoryTokens.isEmpty)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        nameSection
                        timeSection
                        repeatSection
                        appsSection
                        brakesSection
                        PrimaryButton(title: "Save Changes", action: saveChanges, isEnabled: canSave).padding(.top, 4)
                        deleteButton.padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Edit Schedule")
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
        }
        .sheet(isPresented: $showAppPicker) {
            FamilyPickerSheet(isPresented: $showAppPicker, selection: $appSelection)
        }
        .sheet(isPresented: $showBrakePicker) {
            BrakePickerSheet(selected: $brakeLevel)
        }
        .confirmationDialog("Delete Block", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.removeScheduleBlock(id: block.id); dismiss() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This block will be permanently removed.") }
        .onAppear { populate() }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "NAME")
            TextField("Block name...", text: $name)
                .font(.system(size: 16)).foregroundColor(.white).tint(AppTheme.accentBright)
                .padding(.horizontal, 14).frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                TimePickerField(label: "FROM", hour: $fromHour, minute: $fromMinute, period: $fromPeriod)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))

            VStack(alignment: .leading, spacing: 0) {
                TimePickerField(label: "TO", hour: $toHour, minute: $toMinute, period: $toPeriod)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        }
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "REPEAT ON")
            HStack(spacing: 6) {
                ForEach(RepeatDay.allCases, id: \.0.rawValue) { day, label in
                    DayToggleButton(label: label, isSelected: repeatDays.contains(day)) {
                        if repeatDays.contains(day) { repeatDays.remove(day) } else { repeatDays.insert(day) }
                    }
                }
            }
        }
    }

    private var appsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "APP BLOCK LIST")
            SelectedAppsSection(selection: $appSelection, onEditTap: { showAppPicker = true })
        }
    }

    private var brakesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "BRAKES ALLOWED")
            Button { showBrakePicker = true } label: {
                HStack {
                    Image(systemName: brakeLevel.iconName).foregroundColor(AppTheme.textSecondary)
                    Text(brakeLevel.rawValue).font(.system(size: 15)).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(AppTheme.textSecondary).font(.system(size: 13))
                }
                .padding(.horizontal, 14).frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
        }
    }

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            Text("Delete Block")
                .font(.system(size: 15, weight: .medium)).foregroundColor(.red)
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
        }
    }

    private func populate() {
        name = block.name; repeatDays = block.repeatDays
        appSelection = block.appSelection; brakeLevel = block.brakeLevel
        let fh = block.fromTime.hour ?? 0
        fromHour = fh == 0 ? 12 : (fh > 12 ? fh - 12 : fh)
        fromMinute = block.fromTime.minute ?? 0; fromPeriod = fh < 12 ? "AM" : "PM"
        let th = block.toTime.hour ?? 0
        toHour = th == 0 ? 12 : (th > 12 ? th - 12 : th)
        toMinute = block.toTime.minute ?? 0; toPeriod = th < 12 ? "AM" : "PM"
    }

    private func saveChanges() {
        let updated = ScheduleBlock(
            id: block.id, name: name,
            fromTime: DateComponents(hour: to24(fromHour, period: fromPeriod), minute: fromMinute),
            toTime:   DateComponents(hour: to24(toHour,   period: toPeriod),   minute: toMinute),
            repeatDays: repeatDays, appSelection: appSelection,
            brakeLevel: brakeLevel, isEnabled: block.isEnabled
        )
        store.updateScheduleBlock(updated); dismiss()
    }

    private func to24(_ h: Int, period: String) -> Int {
        switch (h, period) {
        case (12, "AM"): return 0; case (12, "PM"): return 12
        case (_, "PM"): return h + 12; default: return h
        }
    }
}

// MARK: - EditTimerBlockView

struct EditTimerBlockView: View {

    let block: TimerBlock
    @StateObject private var store = BlockStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var name:             String                  = ""
    @State private var durationMinutes:  Int                     = 20
    @State private var appSelection:     FamilyActivitySelection = .init()
    @State private var brakeLevel:       BrakeLevel              = .easy
    @State private var showAppPicker       = false
    @State private var showBrakePicker     = false
    @State private var showDurationPicker  = false
    @State private var showDeleteConfirm   = false

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (!appSelection.applicationTokens.isEmpty || !appSelection.categoryTokens.isEmpty)
    }

    var formattedDuration: String {
        durationMinutes < 60 ? "\(durationMinutes) min"
            : "\(durationMinutes / 60) hr\(durationMinutes % 60 > 0 ? " \(durationMinutes % 60) min" : "")"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel(text: "NAME")
                            TextField("Block name...", text: $name)
                                .font(.system(size: 16)).foregroundColor(.white).tint(AppTheme.accentBright)
                                .padding(.horizontal, 14).frame(height: 48)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                        }

                        // Duration
                        VStack(alignment: .leading, spacing: 6) {
                            SectionLabel(text: "DURATION")
                            Button { showDurationPicker = true } label: {
                                HStack {
                                    Text(formattedDuration).font(.system(size: 16)).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textSecondary).font(.system(size: 13))
                                }
                                .padding(.horizontal, 14).frame(height: 48)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                            }
                        }

                        // Apps
                        VStack(alignment: .leading, spacing: 8) {
                            SectionLabel(text: "APP BLOCK LIST")
                            SelectedAppsSection(selection: $appSelection, onEditTap: { showAppPicker = true })
                        }

                        // Brakes
                        VStack(alignment: .leading, spacing: 8) {
                            SectionLabel(text: "BRAKES ALLOWED")
                            Button { showBrakePicker = true } label: {
                                HStack {
                                    Image(systemName: brakeLevel.iconName).foregroundColor(AppTheme.textSecondary)
                                    Text(brakeLevel.rawValue).font(.system(size: 15)).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppTheme.textSecondary).font(.system(size: 13))
                                }
                                .padding(.horizontal, 14).frame(height: 48)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                            }
                        }

                        PrimaryButton(title: "Save Changes", action: saveChanges, isEnabled: canSave)
                            .padding(.top, 4)

                        // Delete
                        Button { showDeleteConfirm = true } label: {
                            Text("Delete Block")
                                .font(.system(size: 15, weight: .medium)).foregroundColor(.red)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Edit Timer")
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
        }
        .sheet(isPresented: $showAppPicker) {
            FamilyPickerSheet(isPresented: $showAppPicker, selection: $appSelection)
        }
        .sheet(isPresented: $showBrakePicker) {
            BrakePickerSheet(selected: $brakeLevel)
        }
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerSheet(isPresented: $showDurationPicker, durationMinutes: $durationMinutes)
        }
        .confirmationDialog("Delete Timer", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.removeTimerBlock(id: block.id); dismiss() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This timer block will be permanently removed.") }
        .onAppear {
            name = block.name
            durationMinutes = block.durationMinutes
            appSelection = block.appSelection
            brakeLevel = block.brakeLevel
        }
    }

    private func saveChanges() {
        // Stop current block first, then update with new data
        if block.isRunning { store.stopTimerBlock(id: block.id) }
        var updated = block
        updated.name = name
        updated.durationMinutes = durationMinutes
        updated.appSelection = appSelection
        updated.brakeLevel = brakeLevel
        updated.startedAt = nil
        // Remove old + add new to trigger proper re-registration
        store.removeTimerBlock(id: block.id)
        store.addTimerBlock(updated)
        dismiss()
    }
}

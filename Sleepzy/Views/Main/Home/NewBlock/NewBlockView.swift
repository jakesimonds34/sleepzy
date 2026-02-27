import SwiftUI
import FamilyControls

struct NewBlockView: View {

    @StateObject private var vm    = NewBlockViewModel()
    @StateObject private var store = BlockStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    modePicker
                    nameField

                    switch vm.blockMode {
                    case .schedule: scheduleBody
                    case .timer:    timerBody
                    }

                    appBlockSection
                    brakesSection

                    PrimaryButton(title: "Save",
                                  action: saveAndDismiss,
                                  isEnabled: vm.canSave)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 8)
            }
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("New Block")
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
        }
        .sheet(isPresented: $vm.showBrakePicker) {
            BrakePickerSheet(selected: $vm.brakeLevel)
        }
        .sheet(isPresented: $vm.showAppPicker) {
            FamilyPickerSheet(isPresented: $vm.showAppPicker,
                              selection:   $vm.appSelection)
        }
        .sheet(isPresented: $vm.showDurationPicker) {
            DurationPickerSheet(isPresented:     $vm.showDurationPicker,
                                durationMinutes: $vm.durationMinutes)
        }
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(BlockMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { vm.blockMode = mode }
                } label: {
                    HStack(spacing: 6) {
                        MyImage(source: .asset(mode == .schedule ? .calendarIcon : .stopwatchIcon))
                            .frame(width: 20, height: 20)
                        
                        Text(mode.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(vm.blockMode == mode ? .white : AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(vm.blockMode == mode ? AppTheme.accent : Color.clear)
                    .clipShape(.rect)
                    .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(AppTheme.pillBackground)
        .clipShape(.rect)
        .cornerRadius(8)
    }

    // MARK: - Name Field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "NAME")
            HStack {
                TextField("Block name...", text: $vm.name)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .tint(AppTheme.accentBright)
                    .colorScheme(.dark)
                
                MyImage(source: .asset(.puzzleIcon))
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
        }
    }

    // MARK: - Schedule Body

    private var scheduleBody: some View {
        VStack(alignment: .leading, spacing: 12) {

            // FROM picker
            VStack(alignment: .leading, spacing: 0) {
                TimePickerField(label: "FROM",
                                hour:   $vm.fromHour,
                                minute: $vm.fromMinute,
                                period: $vm.fromPeriod)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))

            // TO picker
            VStack(alignment: .leading, spacing: 0) {
                TimePickerField(label: "TO",
                                hour:   $vm.toHour,
                                minute: $vm.toMinute,
                                period: $vm.toPeriod)
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))

            VStack(alignment: .leading, spacing: 8) {
                SectionLabel(text: "REPEAT ON")
                HStack(spacing: 6) {
                    ForEach(RepeatDay.allCases, id: \.0.rawValue) { (day, label) in
                        DayToggleButton(label: label,
                                        isSelected: vm.repeatDays.contains(day)) {
                            vm.toggleDay(day)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Timer Body

    private var timerBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "DURATION")
            Button { vm.showDurationPicker = true } label: {
                HStack {
                    Text(vm.formattedDuration)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
        }
    }

    // MARK: - App Block Section

    private var appBlockSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "APP BLOCK LIST")
            SelectedAppsSection(selection: $vm.appSelection,
                                onEditTap: { vm.showAppPicker = true })
        }
    }

    // MARK: - Brakes Section

    private var brakesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "BRAKES ALLOWED")
            Button { vm.showBrakePicker = true } label: {
                HStack {
                    MyImage(source: .asset(vm.brakeLevel.iconName))
                        .frame(width: 24, height: 24)
                    
                    Text(vm.brakeLevel.rawValue)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
        }
    }

    // MARK: - Save

    private func saveAndDismiss() {
        switch vm.blockMode {
        case .schedule: vm.saveScheduleBlock(to: store)
        case .timer:    vm.saveTimerBlock(to: store)
        }
        dismiss()
    }
}

import SwiftUI
import FamilyControls

// MARK: - AppIconRowView

struct AppIconRowView: View {
    let selection: FamilyActivitySelection
    let maxVisible: Int

    var totalCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(selection.applicationTokens.prefix(maxVisible)), id: \.self) { token in
                Label(token).labelStyle(.iconOnly)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.tagBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
            }
            let remaining = maxVisible - selection.applicationTokens.count
            if remaining > 0 {
                ForEach(Array(selection.categoryTokens.prefix(max(0, remaining))), id: \.self) { token in
                    Label(token).labelStyle(.iconOnly)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.tagBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
            }
            if totalCount > maxVisible {
                Text("+\(totalCount - maxVisible)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.tagBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
            }
        }
    }
}

// MARK: - SelectedAppsSection

struct SelectedAppsSection: View {
    @Binding var selection: FamilyActivitySelection
    let onEditTap: () -> Void

    var isEmpty: Bool {
        selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selection.applicationTokens), id: \.self) { token in
                            chipView(label: Label(token)) { selection.applicationTokens.remove(token) }
                        }
                        ForEach(Array(selection.categoryTokens), id: \.self) { token in
                            chipView(label: Label(token)) { selection.categoryTokens.remove(token) }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            Button(action: onEditTap) {
                HStack(spacing: 6) {
                    Image(systemName: isEmpty ? "plus" : "pencil").font(.system(size: 13, weight: .semibold))
                    Text(isEmpty ? "Select apps to block" : "Edit selection").font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 44)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.buttonRadius).stroke(AppTheme.separatorColor, lineWidth: 1))
            }
        }
    }

    @ViewBuilder
    private func chipView<L: View>(label: L, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 5) {
            label.labelStyle(.iconOnly).frame(width: 22, height: 22)
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
        .background(AppTheme.tagBackground).clipShape(Capsule())
    }
}

// MARK: - FamilyPickerSheet

struct FamilyPickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selection: FamilyActivitySelection
    @State private var tempSelection = FamilyActivitySelection()

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $tempSelection)
                .navigationTitle("Select Apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { isPresented = false }.foregroundColor(AppTheme.accentBright)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { selection = tempSelection; isPresented = false }
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(AppTheme.accentBright)
                    }
                }
        }
        .onAppear { tempSelection = selection }
    }
}

// MARK: - DurationPickerSheet

struct DurationPickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var durationMinutes: Int
    private let options = [5, 10, 15, 20, 30, 45, 60, 90, 120]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                List {
                    ForEach(options, id: \.self) { mins in
                        Button {
                            durationMinutes = mins; isPresented = false
                        } label: {
                            HStack {
                                Text(label(for: mins)).foregroundColor(.white).font(.system(size: 16))
                                Spacer()
                                if durationMinutes == mins {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.accentBright)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }.foregroundColor(AppTheme.accentBright)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    private func label(for mins: Int) -> String {
        mins < 60 ? "\(mins) min" : "\(mins / 60) hr\(mins % 60 > 0 ? " \(mins % 60) min" : "")"
    }
}

// MARK: - DayToggleButton

struct DayToggleButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 38, height: 38)
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .background(isSelected ? AppTheme.accent : AppTheme.tagBackground)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedCorner(radius: 8, corners: .allCorners).stroke(Color(hex: isSelected ? "988AE1" : "FFFFFF").opacity(0.4), lineWidth: 0.5))
        }
    }
}

// MARK: - TimePickerField
// Uses DatePicker .graphical — native clock dial, fully interactive, no scroll issues.
// Each picker shows in its own card with a label above it.

struct TimePickerField: View {
    let label: String
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var period: String

    private var dateBinding: Binding<Date> {
        Binding(
            get: {
                var c    = DateComponents()
                c.hour   = to24(hour, period: period)
                c.minute = minute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { d in
                let c  = Calendar.current.dateComponents([.hour, .minute], from: d)
                let h  = c.hour ?? 0
                hour   = h == 0 ? 12 : (h > 12 ? h - 12 : h)
                minute = c.minute ?? 0
                period = h < 12 ? "AM" : "PM"
            }
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            // Label + current value pill
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                    .kerning(1.2)
                Spacer()
                Text(displayTime)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.accentBright)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.accentBright.opacity(0.15))
                    .clipShape(Capsule())
            }

            DatePicker("", selection: dateBinding, displayedComponents: .hourAndMinute)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AppTheme.accentBright)
                .transformEffect(.identity) // prevents any layout override
        }
    }

    private var displayTime: String {
        String(format: "%d:%02d %@", hour, minute, period)
    }

    private func to24(_ h: Int, period: String) -> Int {
        switch (h, period) {
        case (12, "AM"): return 0
        case (12, "PM"): return 12
        case (_, "PM"):  return h + 12
        default:         return h
        }
    }
}

// MARK: - BrakeLevelRow

struct BrakeLevelRow: View {
    let level: BrakeLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                MyImage(source: .asset(level.iconName))
                    .frame(width: 24, height: 24)
                
                Text(level.rawValue).font(.system(size: 15)).foregroundColor(AppTheme.textPrimary)
                Spacer()
                ZStack {
                    Circle().stroke(isSelected ? AppTheme.accentBright : AppTheme.textSecondary, lineWidth: 1.5)
                    if isSelected { Circle().fill(AppTheme.accentBright).padding(4) }
                }
                .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
    }
}

// MARK: - PrimaryButton

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? Color(hex: "0A0E2A") : AppTheme.textSecondary)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(isEnabled ? .white : AppTheme.pillBackground)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
    }
}

// MARK: - SectionLabel

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(AppTheme.textSecondary)
            .kerning(1.2)
    }
}

import SwiftUI
import FamilyControls

// MARK: - DigitalShieldScheduleView
// Matches Image 2 exactly — FROM/TO time pickers + REPEAT ON days

struct DigitalShieldScheduleView: View {

    @StateObject private var store = BlockStore.shared
    @Environment(\.dismiss) private var dismiss

    // FROM state
    @State private var fromHour:   Int    = 10
    @State private var fromMinute: Int    = 30
    @State private var fromPeriod: String = "PM"

    // TO state
    @State private var toHour:   Int    = 8
    @State private var toMinute: Int    = 0
    @State private var toPeriod: String = "AM"

    // Repeat days
    @State private var repeatDays: RepeatDay = .weekdays

    var body: some View {
        VStack(spacing: 0) {
            
            // Custom nav bar (matches Image 2 style)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Title block
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Digital Shield Schedule")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Choose when distracting apps are blocked to\nhelp you sleep better.")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // FROM picker
                    timeSection(label: "FROM", hour: $fromHour, minute: $fromMinute, period: $fromPeriod)
                    
                    // TO picker
                    timeSection(label: "TO", hour: $toHour, minute: $toMinute, period: $toPeriod)
                    
                    // Repeat days
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(text: "REPEAT ON")
                        HStack(spacing: 8) {
                            ForEach(RepeatDay.allCases, id: \.0.rawValue) { day, label in
                                DayToggleButton(
                                    label: label,
                                    isSelected: repeatDays.contains(day)
                                ) {
                                    if repeatDays.contains(day) { repeatDays.remove(day) }
                                    else { repeatDays.insert(day) }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    Spacer(minLength: 32)
                    
                    // Save button — matches Image 2 white pill style
                    Button(action: save) {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "0A0E2A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, 8)
            }
        }
        .background(
            MyImage(source: .asset(.bgSounds))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .onAppear { populate() }
    }

    // MARK: - Time Section (label + digit boxes matching Image 2)

    private func timeSection(
        label: String,
        hour: Binding<Int>,
        minute: Binding<Int>,
        period: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(text: label)

            HStack(spacing: 8) {
                // Hour tens
                digitBox(value: hour.wrappedValue / 10,
                         onTap: { adjustHour(hour, by: 1) },
                         onSwipeDown: { adjustHour(hour, by: -1) })

                // Hour units
                digitBox(value: hour.wrappedValue % 10,
                         onTap: { adjustHour(hour, by: 1) },
                         onSwipeDown: { adjustHour(hour, by: -1) })

                // Colon
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 16)

                // Minute tens
                digitBox(value: minute.wrappedValue / 10,
                         onTap: { adjustMinute(minute, by: 10) },
                         onSwipeDown: { adjustMinute(minute, by: -10) })

                // Minute units
                digitBox(value: minute.wrappedValue % 10,
                         onTap: { adjustMinute(minute, by: 1) },
                         onSwipeDown: { adjustMinute(minute, by: -1) })

                // AM/PM
                periodBox(period: period)
            }
        }
    }

    // Individual digit box — tappable, matches Image 2 dark square style
    private func digitBox(value: Int, onTap: @escaping () -> Void, onSwipeDown: @escaping () -> Void) -> some View {
        Text(String(value))
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 54, height: 60)
            .background(AppTheme.pillBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { v in
                        if v.translation.height > 0 { onSwipeDown() }
                        else { onTap() }
                    }
            )
            .onTapGesture { onTap() }
    }

    private func periodBox(period: Binding<String>) -> some View {
        Button {
            period.wrappedValue = period.wrappedValue == "AM" ? "PM" : "AM"
        } label: {
            Text(period.wrappedValue)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(AppTheme.pillBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Adjust helpers (wrap-around)

    private func adjustHour(_ binding: Binding<Int>, by delta: Int) {
        var h = binding.wrappedValue + delta
        if h > 12 { h = 1 }
        if h < 1  { h = 12 }
        binding.wrappedValue = h
    }

    private func adjustMinute(_ binding: Binding<Int>, by delta: Int) {
        var m = binding.wrappedValue + delta
        if m >= 60 { m = 0 }
        if m < 0   { m = 59 }
        binding.wrappedValue = m
    }

    // MARK: - Populate from current shield

    private func populate() {
        guard let shield = store.digitalShield else { return }

        let sh = shield.startTime.hour ?? 22
        fromHour   = sh == 0 ? 12 : (sh > 12 ? sh - 12 : sh)
        fromMinute = shield.startTime.minute ?? 30
        fromPeriod = sh < 12 ? "AM" : "PM"

        let eh = shield.endTime.hour ?? 8
        toHour   = eh == 0 ? 12 : (eh > 12 ? eh - 12 : eh)
        toMinute = shield.endTime.minute ?? 0
        toPeriod = eh < 12 ? "AM" : "PM"

        repeatDays = shield.repeatDays
    }

    // MARK: - Save

    private func save() {
        guard var shield = store.digitalShield else { return }
        shield.startTime  = DateComponents(hour: to24(fromHour, period: fromPeriod), minute: fromMinute)
        shield.endTime    = DateComponents(hour: to24(toHour,   period: toPeriod),   minute: toMinute)
        shield.repeatDays = repeatDays
        store.updateDigitalShield(shield)
        dismiss()
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

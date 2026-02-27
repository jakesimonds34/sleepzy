import Foundation
import FamilyControls
import Combine

@MainActor
final class NewBlockViewModel: ObservableObject {

    // MARK: - Shared
    @Published var blockMode:    BlockMode               = .schedule
    @Published var name:         String                  = ""
    @Published var appSelection: FamilyActivitySelection = FamilyActivitySelection()
    @Published var brakeLevel:   BrakeLevel              = .easy

    // Sheet flags
    @Published var showBrakePicker:    Bool = false
    @Published var showAppPicker:      Bool = false
    @Published var showDurationPicker: Bool = false

    // MARK: - Schedule mode
    @Published var fromHour:   Int    = 10
    @Published var fromMinute: Int    = 0
    @Published var fromPeriod: String = "PM"

    @Published var toHour:   Int    = 8
    @Published var toMinute: Int    = 0
    @Published var toPeriod: String = "AM"

    @Published var repeatDays: RepeatDay = []

    // MARK: - Timer mode
    @Published var durationMinutes: Int = 20

    var formattedDuration: String {
        durationMinutes < 60
            ? "\(durationMinutes) min"
            : "\(durationMinutes / 60) hr\(durationMinutes % 60 > 0 ? " \(durationMinutes % 60) min" : "")"
    }

    // MARK: - Validation
    var canSave: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let hasApps = !appSelection.applicationTokens.isEmpty ||
                      !appSelection.categoryTokens.isEmpty
        return hasName && hasApps
    }

    // MARK: - Actions

    func toggleDay(_ day: RepeatDay) {
        if repeatDays.contains(day) { repeatDays.remove(day) }
        else                        { repeatDays.insert(day) }
    }

    func saveScheduleBlock(to store: BlockStore) {
        let block = ScheduleBlock(
            name: name,
            fromTime: DateComponents(hour: to24(fromHour, period: fromPeriod),
                                     minute: fromMinute),
            toTime:   DateComponents(hour: to24(toHour, period: toPeriod),
                                     minute: toMinute),
            repeatDays:    repeatDays,
            appSelection:  appSelection,
            brakeLevel:    brakeLevel
        )
        store.addScheduleBlock(block)
    }

    func saveTimerBlock(to store: BlockStore) {
        let block = TimerBlock(
            name:            name,
            durationMinutes: durationMinutes,
            appSelection:    appSelection,
            brakeLevel:      brakeLevel
        )
        store.addTimerBlock(block)
    }

    // MARK: - Helpers

    private func to24(_ h: Int, period: String) -> Int {
        switch (h, period) {
        case (12, "AM"): return 0
        case (12, "PM"): return 12
        case (_, "PM"):  return h + 12
        default:         return h
        }
    }
}

import Foundation
import FamilyControls
import ManagedSettings

// MARK: - BlockMode
enum BlockMode: String, CaseIterable, Codable, Identifiable {
    case schedule = "Schedule"
    case timer    = "Timer"
    
    var id: String { rawValue }
}

// MARK: - BrakeLevel
enum BrakeLevel: String, CaseIterable, Codable, Identifiable {
    case easy     = "Yes, make it easy"
    case harder   = "Yes but make it harder"
    case hardcore = "No way, I am hardcore"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .easy:     return "shield.slash"
        case .harder:   return "shield"
        case .hardcore: return "lock.shield.fill"
        }
    }
}

// MARK: - RepeatDay
struct RepeatDay: OptionSet, Codable {
    let rawValue: Int
    
    static let monday    = RepeatDay(rawValue: 1 << 0)
    static let tuesday   = RepeatDay(rawValue: 1 << 1)
    static let wednesday = RepeatDay(rawValue: 1 << 2)
    static let thursday  = RepeatDay(rawValue: 1 << 3)
    static let friday    = RepeatDay(rawValue: 1 << 4)
    static let saturday  = RepeatDay(rawValue: 1 << 5)
    static let sunday    = RepeatDay(rawValue: 1 << 6)
    
    static let weekdays: RepeatDay = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekends: RepeatDay = [.saturday, .sunday]
    static let allDays:  RepeatDay = [.weekdays, .weekends]
    
    static let allCases: [(RepeatDay, String)] = [
        (.monday, "M"), (.tuesday, "T"), (.wednesday, "W"),
        (.thursday, "T"), (.friday, "F"), (.saturday, "S"), (.sunday, "S")
    ]
}

// MARK: - AppBlock (Schedule)
struct ScheduleBlock: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var fromTime: DateComponents   // hour + minute
    var toTime: DateComponents     // hour + minute
    var repeatDays: RepeatDay
    var appSelection: FamilyActivitySelection
    var brakeLevel: BrakeLevel
    var isEnabled: Bool = true
    
    // Convenience
    var displayFromTime: String { formatTime(fromTime) }
    var displayToTime:   String { formatTime(toTime)   }
    
    private func formatTime(_ dc: DateComponents) -> String {
        let hour   = dc.hour ?? 0
        let minute = dc.minute ?? 0
        let period = hour < 12 ? "AM" : "PM"
        let h      = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", h, minute, period)
    }
}

// MARK: - AppBlock (Timer)
struct TimerBlock: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var durationMinutes: Int
    var appSelection: FamilyActivitySelection
    var brakeLevel: BrakeLevel
    var isEnabled: Bool = true
    var startedAt: Date?
    
    var isRunning: Bool { startedAt != nil }
    
    var remainingSeconds: Int? {
        guard let start = startedAt else { return nil }
        let elapsed = Int(Date().timeIntervalSince(start))
        return max(0, durationMinutes * 60 - elapsed)
    }
}

// MARK: - Digital Shield (Home upcoming block)
struct DigitalShield: Identifiable {
    var id: UUID = UUID()
    var name: String = "Digital Shield"
    var startTime: DateComponents
    var endTime: DateComponents
    var appSelection: FamilyActivitySelection
    var isEnabled: Bool = true
    
    var minutesUntilStart: Int {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let nowMins   = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let startMins = (startTime.hour ?? 0) * 60 + (startTime.minute ?? 0)
        return max(0, startMins - nowMins)
    }
    
    var displayStartTime: String { formatTime(startTime) }
    var displayEndTime:   String { formatTime(endTime)   }
    
    private func formatTime(_ dc: DateComponents) -> String {
        let hour   = dc.hour ?? 0
        let minute = dc.minute ?? 0
        let period = hour < 12 ? "AM" : "PM"
        let h      = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", h, minute, period)
    }
}

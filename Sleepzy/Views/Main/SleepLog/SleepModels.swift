import Foundation
import HealthKit

// MARK: - Sleep Stage

enum SleepStage: String, CaseIterable {
    case awake      = "Awake"
    case rem        = "REM"
    case lightSleep = "Light Sleep"
    case deepSleep  = "Deep Sleep"

    var color: String {
        switch self {
        case .awake:      return "5939A8"   // purple
        case .rem:        return "FF7694"   // pink
        case .lightSleep: return "68E468"   // green
        case .deepSleep:  return "417BE6"   // blue
        }
    }

    var dotColorHex: String { color }
}

// MARK: - Sleep Stage Segment (one bar in the chart)

struct SleepSegment: Identifiable {
    let id = UUID()
    let stage: SleepStage
    let startHour: Double   // e.g. 1.5 = 1:30 AM offset from sleep start
    let durationHours: Double
}

// MARK: - Sleep Session (one night)

struct SleepSession: Identifiable {
    let id = UUID()
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    let segments: [SleepSegment]

    var totalDuration: TimeInterval { wakeTime.timeIntervalSince(bedtime) }

    var totalHours: Double { totalDuration / 3600 }

    var awakeMinutes: Int {
        Int(segments.filter { $0.stage == .awake }.map(\.durationHours).reduce(0,+) * 60)
    }
    var remMinutes: Int {
        Int(segments.filter { $0.stage == .rem }.map(\.durationHours).reduce(0,+) * 60)
    }
    var lightMinutes: Int {
        Int(segments.filter { $0.stage == .lightSleep }.map(\.durationHours).reduce(0,+) * 60)
    }
    var deepMinutes: Int {
        Int(segments.filter { $0.stage == .deepSleep }.map(\.durationHours).reduce(0,+) * 60)
    }

    // Simple quality score 0–100
    var qualityPercent: Int {
        let deep  = Double(deepMinutes)  / (totalDuration / 60) * 100
        let rem   = Double(remMinutes)   / (totalDuration / 60) * 100
        let light = Double(lightMinutes) / (totalDuration / 60) * 100
        let score = (deep * 0.5) + (rem * 0.3) + (light * 0.2)
        return min(100, max(0, Int(score)))
    }

    var qualityLabel: String {
        switch qualityPercent {
        case 80...: return "Good"
        case 60..<80: return "Fair"
        default: return "Poor"
        }
    }

    var displayBedtime: String  { formatTime(bedtime)  }
    var displayWakeTime: String { formatTime(wakeTime) }

    var displayDuration: String {
        let h = Int(totalHours)
        let m = Int((totalHours - Double(h)) * 60)
        return "\(h) h \(m) m"
    }

    var displayDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM"
        return f.string(from: date)
    }

    private func formatTime(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: d)
    }
}

// MARK: - Period

enum SleepPeriod: String, CaseIterable {
    case weekly  = "Weekly"
    case monthly = "Monthly"
    case yearly  = "Yearly"
}

// MARK: - Stage Summary (for Analytics detail)

struct StageSummary {
    let stage: SleepStage
    let minutes: Int
    let percent: Int
    let level: String      // "High" / "Normal" / "Low"
    let levelColor: String // hex
}

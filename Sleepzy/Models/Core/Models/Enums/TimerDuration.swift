//
//  TimerDuration.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation

// MARK: - Timer Duration Enum
enum TimerDuration: String, Codable {
    case fifteenMin = "15 Minutes"
    case thirtyMin = "30 Minutes"
    case oneHour = "1 Hour"
    case twoHours = "2 Hours"
    case custom = "Custom"
    
    var minutes: Int {
        switch self {
        case .fifteenMin: return 15
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .twoHours: return 120
        case .custom: return 0
        }
    }
}

//
//  BlockConfiguration.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation
import FamilyControls

//// MARK: - Block Configuration
//struct BlockConfiguration: Codable {
//    let name: String
//    let type: BlockTab
//    let fromHour: Int
//    let fromMinute: Int
//    let fromPeriod: Period
//    let toHour: Int
//    let toMinute: Int
//    let toPeriod: Period
//    let selectedDays: Set<Weekday>
//    let durationMinutes: Int
//    let selectedApps: FamilyActivitySelection
//    let brakeType: BrakeType
//    
//    var timeRange: String {
//        if type == .timer {
//            return "\(durationMinutes) min"
//        } else {
//            return "\(fromHour):\(String(format: "%02d", fromMinute)) \(fromPeriod.rawValue) - \(toHour):\(String(format: "%02d", toMinute)) \(toPeriod.rawValue)"
//        }
//    }
//    
//    var daysString: String {
//        if selectedDays.count == 7 {
//            return "Every day"
//        } else if selectedDays.isEmpty {
//            return "No days selected"
//        } else {
//            return selectedDays.map { $0.rawValue }.joined(separator: ", ")
//        }
//    }
//}

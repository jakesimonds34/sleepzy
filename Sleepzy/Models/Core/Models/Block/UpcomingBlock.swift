//
//  UpcomingBlock.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation
import FamilyControls

//// MARK: - Upcoming Block
//struct UpcomingBlock: Identifiable {
//    let id: UUID
//    let name: String
//    let timeRemaining: String
//    let startTime: String
//    let endTime: String
//    
//    var formattedTimeRemaining: String {
//        guard let minutes = Int(timeRemaining) else {
//            return timeRemaining
//        }
//        
//        if minutes < 60 {
//            return "\(minutes) min"
//        } else {
//            let hours = minutes / 60
//            let mins = minutes % 60
//            if mins == 0 {
//                return "\(hours)h"
//            }
//            return "\(hours)h \(mins)m"
//        }
//    }
//}
//
//// MARK: - Digital Shield Status
//struct DigitalShield {
//    let status: String
//    let timing: String
//}
//
//// MARK: - Locked App
//struct LockedApp: Identifiable, Hashable {
//    let id = UUID()
//    let icon: String
//}
//
//// MARK: - Codable Extensions
//
extension BlockConfiguration {
    enum CodingKeys: String, CodingKey {
        case name, type, fromHour, fromMinute, fromPeriod
        case toHour, toMinute, toPeriod, selectedDays
        case durationMinutes, brakeType
        case appTokensCount, categoryTokensCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type == .schedule ? "schedule" : "timer", forKey: .type)
        try container.encode(fromHour, forKey: .fromHour)
        try container.encode(fromMinute, forKey: .fromMinute)
        try container.encode(fromPeriod.rawValue, forKey: .fromPeriod)
        try container.encode(toHour, forKey: .toHour)
        try container.encode(toMinute, forKey: .toMinute)
        try container.encode(toPeriod.rawValue, forKey: .toPeriod)
        try container.encode(Array(selectedDays).map { $0.rawValue }, forKey: .selectedDays)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(brakeType.rawValue, forKey: .brakeType)
        try container.encode(selectedApps.applicationTokens.count, forKey: .appTokensCount)
        try container.encode(selectedApps.categoryTokens.count, forKey: .categoryTokensCount)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        
        let typeString = try container.decode(String.self, forKey: .type)
        type = typeString == "schedule" ? .schedule : .timer
        
        fromHour = try container.decode(Int.self, forKey: .fromHour)
        fromMinute = try container.decode(Int.self, forKey: .fromMinute)
        
        let fromPeriodString = try container.decode(String.self, forKey: .fromPeriod)
        fromPeriod = fromPeriodString == "AM" ? .am : .pm
        
        toHour = try container.decode(Int.self, forKey: .toHour)
        toMinute = try container.decode(Int.self, forKey: .toMinute)
        
        let toPeriodString = try container.decode(String.self, forKey: .toPeriod)
        toPeriod = toPeriodString == "AM" ? .am : .pm
        
        let daysArray = try container.decode([String].self, forKey: .selectedDays)
        selectedDays = Set(daysArray.compactMap { WeekDay(rawValue: $0) })
        
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        
        let brakeTypeString = try container.decode(String.self, forKey: .brakeType)
        brakeType = BrakeType(rawValue: brakeTypeString) ?? .takeItEasy
        
        selectedApps = FamilyActivitySelection()
    }
}

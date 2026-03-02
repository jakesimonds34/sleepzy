//
//  Profile.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 09/02/2026.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    var fullName: String
    var email: String?
    var createdAt: Date?
    var goal: String?
    var biggestDistraction: String?
    var ageRange: String?
    var gender: String?
    var stayAsleep: String?
    var earlyWakeupRating: String?
    var dailyFunctionInterference: String?
    var bedHour: Double?
    var wakeHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName                  = "full_name"
        case email                     = "email"
        case createdAt                 = "created_at"
        case goal                      = "goal"
        case biggestDistraction        = "biggest_distraction"
        case ageRange                  = "age_range"
        case gender                    = "gender"
        case stayAsleep                = "stay_asleep"
        case earlyWakeupRating         = "early_wakeup_rating"
        case dailyFunctionInterference = "daily_function_interference"
        case bedHour                   = "bed_hour"
        case wakeHour                  = "wake_hour"
    }
}

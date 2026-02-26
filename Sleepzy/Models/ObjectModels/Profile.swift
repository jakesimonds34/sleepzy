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
//    var currentSleepScore: String?
//    var potentialSleepScore: String?
//    var distractingApps: String?
//    var focusProtectionRepeatOn: [String: Bool]?
//    var sleepTime: Double?
//    var wakeUp: Double?
//    var bedTime: Double?
//    var focusProtectionFrom: Date?
//    var focusProtectionTo: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email = "email"
        case createdAt = "created_at"
        case goal = "goal"
        case biggestDistraction = "biggest_distraction"
        case ageRange = "age_range"
        case gender = "gender"
        case stayAsleep = "stay_asleep"
        case earlyWakeupRating = "early_wakeup_rating"
        case dailyFunctionInterference = "daily_function_interference"
//        case currentSleepScore = "current_sleep_score"
//        case potentialSleepScore = "potential_sleep_score"
//        case distractingApps = "distracting_apps"
//        case focusProtectionRepeatOn = "focus_protection_repeat_on"
//        case sleepTime = "sleep_time"
//        case wakeUp = "wake_up"
//        case bedTime = "bed_time"
//        case focusProtectionFrom = "focus_protection_from"
//        case focusProtectionTo = "focus_protection_to"
    }
}

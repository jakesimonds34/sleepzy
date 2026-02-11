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
    var createdAt: Date?
    var ageRange: String?
    var gender: String?
    var email: String?
    var goal: String?
    var bedTime: Double?
    var sleepTime: Double?
    var wakeUp: Double?
    var biggestDistraction: String?
    var stayAsleep: String?
    var earlyWakeupRating: String?
    var dailyFunctionInterference: String?
    var currentSleepScore: String?
    var potentialSleepScore: String?
    var distractingApps: String?
    var focusProtectionFrom: Date?
    var focusProtectionTo: Date?
    var focusProtectionRepeatOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case createdAt = "created_at"
        case ageRange = "age_range"
        case gender = "gender"
        case email = "email"
        case goal = "goal"
        case bedTime = "bed_time"
        case sleepTime = "sleep_time"
        case biggestDistraction = "biggest_distraction"
        case earlyWakeupRating = "early_wakeup_rating"
        case dailyFunctionInterference = "daily_function_interference"
        case currentSleepScore = "current_sleep_score"
        case potentialSleepScore = "potential_sleep_score"
        case distractingApps = "distracting_apps"
        case focusProtectionFrom = "focus_protection_from"
        case focusProtectionTo = "focus_protection_to"
        case focusProtectionRepeatOn = "focus_protection_repeat_on"
    }
}

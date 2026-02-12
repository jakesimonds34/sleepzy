//
//  BrakeType.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation

// MARK: - Brake Type
enum BrakeType: String, CaseIterable, Codable {
    case takeItEasy = "Yes Take it easy"
    case makeItHarder = "Yes but make it harder"
    case hardcore = "No way, I am hardcore"
    
    var title: String {
        switch self {
        case .takeItEasy: return "Yes, take it easy"
        case .makeItHarder: return "Yes but make it harder"
        case .hardcore: return "No way, I am hardcore"
        }
    }
    
    var description: String {
        switch self {
        case .takeItEasy: return "You can bypass with one tap"
        case .makeItHarder: return "Requires solving a challenge"
        case .hardcore: return "No breaks until schedule ends"
        }
    }
    
    var icon: String {
        switch self {
        case .takeItEasy: return "hand.raised.slash"
        case .makeItHarder: return "shield.lefthalf.filled"
        case .hardcore: return "shield.fill"
        }
    }
}

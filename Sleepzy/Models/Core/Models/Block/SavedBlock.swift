//
//  SavedBlock.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import Foundation
import FamilyControls

// MARK: - Saved Block
struct SavedBlock: Identifiable, Codable {
    let id: UUID
    var configuration: BlockConfiguration
    var isActive: Bool
    let createdAt: Date
    var updatedAt: Date?
    var lastActivated: Date?
    
    var displayName: String {
        configuration.name.isEmpty ? "Unnamed Block" : configuration.name
    }
    
    var typeIcon: String {
        configuration.type == .schedule ? "calendar" : "timer"
    }
    
    var statusColor: String {
        isActive ? "green" : "gray"
    }
}

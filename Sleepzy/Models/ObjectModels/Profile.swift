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
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case createdAt = "created_at"
    }
}

//
//  ProfileRepository.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 09/02/2026.
//

import Foundation
import Supabase

protocol ProfileRepositoryProtocol {
    func createProfile(_ profile: Profile) async throws
    func getProfile(by id: UUID) async throws -> Profile
    func updateProfile(id: UUID, fullName: String, goal: String) async throws
    func updateSleepSchedule(id: UUID, bedHour: Double, wakeHour: Double) async throws
    func deleteProfile(id: UUID) async throws
}

final class ProfileRepository: ProfileRepositoryProtocol {
    
    private let client = SupabaseService.shared.client
    
    func createProfile(_ profile: Profile) async throws {
        try await client
            .from("profiles")
            .insert(profile)
            .execute()
    }
    
    func getProfile(by id: UUID) async throws -> Profile {
        let response: PostgrestResponse<Profile> = try await client
            .from("profiles")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        return response.value
    }
    
    func updateProfile(id: UUID, fullName: String, goal: String) async throws {
        try await client
            .from("profiles")
            .update(["full_name": fullName, "goal": goal])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func updateSleepSchedule(id: UUID, bedHour: Double, wakeHour: Double) async throws {
        try await client
            .from("profiles")
            .update(["bed_hour": bedHour, "wake_hour": wakeHour])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteProfile(id: UUID) async throws {
        try await client
            .from("profiles")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

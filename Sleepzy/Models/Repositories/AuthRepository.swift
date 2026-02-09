//
//  AuthRepository.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 09/02/2026.
//

import Foundation
import Supabase

protocol AuthRepositoryProtocol {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async -> User?
}

final class AuthRepository: AuthRepositoryProtocol {
    
    private let client = SupabaseService.shared.client
    
    func signUp(email: String, password: String) async throws -> User {
        let result = try await client.auth.signUp(email: email, password: password)
        let user = result.user
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)
        return session.user
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async -> User? {
        do {
            let session = try await client.auth.session
            return session.user
        } catch {
            return nil
        }
    }
}

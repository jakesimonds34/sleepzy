//
//  AuthRepository.swift
//  Sleepzy
//

import Foundation
import Supabase

protocol AuthRepositoryProtocol {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async -> User?
    func forgotPassword(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func deleteUser() async throws
}

final class AuthRepository: AuthRepositoryProtocol {

    private let client = SupabaseService.shared.client

    func signUp(email: String, password: String) async throws -> User {
        let result = try await client.auth.signUp(email: email, password: password)
        return result.user
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

    func forgotPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func updatePassword(newPassword: String) async throws {
        try await client.auth.update(user: UserAttributes(password: newPassword))
    }

    // ✅ حذف الـ auth user عبر Supabase Edge Function
    func deleteUser() async throws {
        guard let userId = try? await client.auth.session.user.id else {
            throw NSError(domain: "AuthRepository", code: 401,
                         userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        try await client.functions.invoke(
            "delete-user",
            options: FunctionInvokeOptions(
                body: ["user_id": userId.uuidString]
            )
        )
    }
}

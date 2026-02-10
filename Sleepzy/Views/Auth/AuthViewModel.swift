//
//  AuthViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 09/02/2026.
//

import Combine
import Supabase
import Foundation
import SwiftMessages

class AuthViewModel: ObservableObject {
    //MARK: Auth parameters
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var verificationCode = ""
    @Published var otpLength = 6
    
    //MARK: Services parameters
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    //MARK: Destination views
    @Published var showOnboarding: Bool = false
    @Published var showSignup: Bool = false
    @Published var showForgotPassword: Bool = false
    @Published var showEnterCode: Bool = false
    @Published var showNewPassword: Bool = false
    
    //MARK: Objects
    @Published var user: User?
    @Published var profile: Profile?
    
    //MARK: Protocols
    private let authRepo: AuthRepositoryProtocol
    private let profileRepo: ProfileRepositoryProtocol
    
    init(
        authRepo: AuthRepositoryProtocol = AuthRepository(),
        profileRepo: ProfileRepositoryProtocol = ProfileRepository()
    ) {
        self.authRepo = authRepo
        self.profileRepo = profileRepo
    }
    
    //MARK: Load session
    func loadSession() async {
        user = await authRepo.getCurrentUser()
        
        if let user = user {
            do {
                profile = try await profileRepo.getProfile(by: user.id)
            } catch {
                print("No profile found")
            }
        }
    }
    
    //MARK: Signup
    func signUp(fullName: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newUser = try await authRepo.signUp(email: email, password: password)
            self.user = newUser
            
            let profile = Profile(id: newUser.id, fullName: fullName)
            try await profileRepo.createProfile(profile)
            self.profile = profile
            
            self.showOnboarding.toggle()
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
        
        isLoading = false
    }
    
    //MARK: Sign in
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loggedUser = try await authRepo.signIn(email: email, password: password)
            self.user = loggedUser
            self.profile = try await profileRepo.getProfile(by: loggedUser.id)
            
            AppEnvironment.shared.appStatus = .home
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
        
        isLoading = false
    }
    
    //MARK: Sign out
    func signOut() async {
        do {
            try await authRepo.signOut()
            user = nil
            profile = nil
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
    }
    
    //MARK: Forgot password
    func forgotPassword(email: String) async {
        isLoading = true
        
        do {
            try await authRepo.forgotPassword(email: email)
            successMessage = "Password reset link has been sent to your email."
            Alerts.show(title: nil, body: successMessage ?? "Success", theme: .success)
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
    }
    
    //MARK: Update password
    func updatePassword(newPassword: String) async {
        isLoading = true
        
        do {
            try await authRepo.updatePassword(newPassword: newPassword)
            successMessage = "Password has been successfully updated."
            Alerts.show(title: nil, body: successMessage ?? "", theme: .success)
            
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
    }
    
    //MARK: Login validations
    var isSignInValidated: Bool {
        if email.isEmpty || !email.isValidEmail() {
            Alerts.show(title: nil, body: "Invalid email address", theme: .warning)
            return false
        }
        
        if password.count < 6 {
            Alerts.show(title: nil, body: "Password must be at least 6 characters long.", theme: .warning)
            return false
        }
        
        return true
    }
}

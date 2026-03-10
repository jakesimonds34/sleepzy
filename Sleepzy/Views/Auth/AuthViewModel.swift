//
//  AuthViewModel.swift
//  Sleepzy
//

import Combine
import Supabase
import Foundation
import StoreKit
import SuperwallKit
import SwiftMessages

class AuthViewModel: ObservableObject {
    //MARK: Auth parameters
    @Published var fullName: String = ""
    #if DEBUG
    @Published var email: String = "saadi.dalloul@gmail.com"
    @Published var password: String = "123123123"
    #else
    @Published var email: String = ""
    @Published var password: String = ""
    #endif
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
    @Published var isSignedUp: Bool = false
    
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
    
    // MARK: - Load Session
    func loadSession() async {
        user = await authRepo.getCurrentUser()
        
        if let user = user {
            do {
                let fetchedProfile = try await profileRepo.getProfile(by: user.id)
                profile = fetchedProfile
                Settings.shared.currentUser = fetchedProfile

                // ✅ مزامنة UserProfileStore مع بيانات Supabase
                syncProfileStore(from: fetchedProfile)

                // ✅ إعادة جدولة Wind Down إذا كان مفعّلاً
                if UserProfileStore.shared.profile.windDownNotification {
                    await WindDownManager.shared.scheduleFromProfile()
                }

                // ✅ تحقق من حالة الاشتراك عبر Superwall
                let status = Superwall.shared.subscriptionStatus
                if case .active = status {
                    AppEnvironment.shared.appStatus = .home
                } else {
                    await MainActor.run {
                        SuperwallService.presentPaywall(onPurchase: {
                            AppEnvironment.shared.appStatus = .home
                        })
                    }
                }
            } catch {
                print("No profile found: \(error)")
            }
        }
    }

    // MARK: - Sync UserProfileStore from Supabase Profile
    // يُستدعى عند loadSession وعند signIn
    // يضمن أن UserProfileStore دائماً محدّث بأحدث بيانات من الـ backend
    private func syncProfileStore(from profile: Profile) {
        let store = UserProfileStore.shared

        // الاسم
        let parts = profile.fullName.split(separator: " ")
        store.profile.firstName = parts.first.map(String.init) ?? profile.fullName
        store.profile.lastName  = parts.dropFirst().joined(separator: " ")

        // الهدف
        store.profile.sleepGoal = profile.goal ?? "Better Sleep"

        // ✅ وقت النوم — المصدر الأساسي الحقيقي
        if let bed = profile.bedHour {
            store.profile.bedHour = bed
            WindDownManager.shared.saveBedHour(bed)
        }
        if let wake = profile.wakeHour {
            store.profile.wakeHour = wake
        }

        store.save()
    }
    
    //MARK: Signup
    func signUp(fullName: String, email: String, password: String, profile: Profile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newUser = try await authRepo.signUp(email: email, password: password)
            self.user = newUser
            
            let profile = Profile(
                id: newUser.id,
                fullName: fullName,
                email: email,
                createdAt: Date(),
                goal: profile.goal,
                biggestDistraction: profile.biggestDistraction,
                ageRange: profile.ageRange,
                gender: profile.gender,
                stayAsleep: profile.stayAsleep,
                earlyWakeupRating: profile.earlyWakeupRating,
                dailyFunctionInterference: profile.dailyFunctionInterference
            )
            
            try await profileRepo.createProfile(profile)
            self.profile = profile
            
            Settings.shared.currentUser = profile
            isSignedUp = true
            requestReview()
            // ✅ لا ننتقل لـ Home هنا — Superwall سيفعل ذلك بعد الشراء
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
            let fetchedProfile = try await profileRepo.getProfile(by: loggedUser.id)
            self.profile = fetchedProfile

            Settings.shared.currentUser = fetchedProfile

            // ✅ مزامنة UserProfileStore عند تسجيل الدخول
            syncProfileStore(from: fetchedProfile)

            // ✅ إعادة جدولة Wind Down إذا كان مفعّلاً
            if UserProfileStore.shared.profile.windDownNotification {
                await WindDownManager.shared.scheduleFromProfile()
            }
//            AppEnvironment.shared.appStatus = .home
            isSignedUp = true
            requestReview()

            // ✅ تحقق من حالة الاشتراك عبر Superwall
            let status = Superwall.shared.subscriptionStatus
            if case .active = status {
                // مشترك → انتقل مباشرة
                AppEnvironment.shared.appStatus = .home
            } else {
                // غير مشترك → اعرض الـ paywall
                await MainActor.run {
                    SuperwallService.presentPaywall(onPurchase: {
                        AppEnvironment.shared.appStatus = .home
                    })
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Account
    func deleteAccount() async {
        guard let userId = Settings.shared.currentUser?.id else {
            Alerts.show(title: nil, body: "User not found", theme: .error)
            return
        }
        isLoading = true

        do {
            // ١. احذف الـ profile من Supabase
            try await profileRepo.deleteProfile(id: userId)
            // ٢. احذف الـ auth user من Supabase
            try await authRepo.deleteUser()
            // ٣. نظّف المحلي
            Settings.shared.resetUserSettings()
            user = nil
            profile = nil
            AppEnvironment.shared.appStatus = .loading
        } catch {
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }

        isLoading = false
    }

    //MARK: Sign out
    func signOut() async {
        do {
            try await authRepo.signOut()
            Settings.shared.resetUserSettings()
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
        
        isLoading = false
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
        
        isLoading = false
    }
    
    // MARK: - Update Profile
    func updateProfile(fullName: String, goal: String) async {
        guard let userId = Settings.shared.currentUser?.id else {
            Alerts.show(title: nil, body: "User not found", theme: .error)
            return
        }
        isLoading = true
        
        do {
            try await profileRepo.updateProfile(id: userId, fullName: fullName, goal: goal)
            
            profile?.fullName = fullName
            profile?.goal = goal
            Settings.shared.currentUser?.fullName = fullName
            Settings.shared.currentUser?.goal = goal
            
            let store = UserProfileStore.shared
            let parts = fullName.split(separator: " ")
            store.profile.firstName = parts.first.map(String.init) ?? fullName
            store.profile.lastName  = parts.dropFirst().joined(separator: " ")
            store.profile.sleepGoal = goal
            store.save()
            
        } catch {
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Update Sleep Schedule
    func updateSleepSchedule(bedHour: Double, wakeHour: Double) async {
        guard let userId = Settings.shared.currentUser?.id else { return }
        isLoading = true
        
        do {
            try await profileRepo.updateSleepSchedule(id: userId, bedHour: bedHour, wakeHour: wakeHour)
            
            // تحديث جميع المصادر
            profile?.bedHour = bedHour
            profile?.wakeHour = wakeHour
            Settings.shared.currentUser?.bedHour = bedHour
            Settings.shared.currentUser?.wakeHour = wakeHour
            UserProfileStore.shared.profile.bedHour = bedHour
            UserProfileStore.shared.profile.wakeHour = wakeHour
            UserProfileStore.shared.save()

            // ✅ احفظ في WindDownManager أيضاً
            WindDownManager.shared.saveBedHour(bedHour)
            
        } catch {
            Alerts.show(title: nil, body: error.localizedDescription, theme: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Signup Validation
    var isSignUpValidated: Bool {
        validateFullName() && validateEmail() && validatePassword() && validatePasswordMatch()
    }
    
    // MARK: - Login Validation
    var isSignInValidated: Bool {
        validateEmail() && validatePassword()
    }
    
    func validateFullName() -> Bool {
        guard !fullName.isEmpty else {
            Alerts.show(title: nil, body: "Full name is required", theme: .warning)
            return false
        }
        return true
    }

    func validateEmail() -> Bool {
        guard !email.isEmpty, email.isValidEmail() else {
            Alerts.show(title: nil, body: "Invalid email address", theme: .warning)
            return false
        }
        return true
    }

    func validatePassword() -> Bool {
        guard password.count >= 6 else {
            Alerts.show(title: nil, body: "Password must be at least 6 characters long.", theme: .warning)
            return false
        }
        return true
    }

    func validatePasswordMatch() -> Bool {
        guard password == confirmPassword else {
            Alerts.show(title: nil, body: "Password and confirmation do not match.", theme: .warning)
            return false
        }
        return true
    }
    // MARK: - Request Review
    @MainActor
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

}

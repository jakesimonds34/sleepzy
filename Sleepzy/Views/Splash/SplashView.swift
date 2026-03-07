//
//  SplashView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

// MARK: - PendingSignup
// ✅ يحمل بيانات الـ Signup المؤقتة ريثما يكمل المستخدم الـ Onboarding
struct PendingSignup: Hashable {
    let fullName: String
    let email: String
    let password: String
}

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    case onboarding                                    // Splash → Onboarding عادي
    case login                                         // Splash → Login
    case signup(profile: Profile?)                     // Onboarding → Signup
    case onboardingForSignup(pending: PendingSignup)   // ✅ Signup → Onboarding لجمع البيانات
    case forgotPassword                                // Login → ForgotPassword
}

// ✅ Profile Hashable لاستخدامه في AppRoute
extension Profile: Hashable {
    public static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - SplashView
struct SplashView: View {
    @StateObject var viewModel = SplashViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingView(path: $path, pendingSignup: nil)

                    case .login:
                        LoginView(path: $path)

                    case .signup(let profile):
                        SignupView(path: $path, profile: profile)

                    case .onboardingForSignup(let pending):
                        // ✅ نفس الـ OnboardingView لكن يعرف أن بعده يكمل التسجيل تلقائياً
                        OnboardingView(path: $path, pendingSignup: pending)

                    case .forgotPassword:
                        ForgotPasswordView()
                    }
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            MyImage(source: .asset(.bgSplash))
                .scaledToFill()

            VStack(spacing: 50) {
                VStack(spacing: 10) {
                    MyImage(source: .asset(.logoSplash))
                        .scaledToFit()
                        .frame(width: 277)

                    Text("Better Sleep Wakeup Happier")
                        .font(.appRegular(size: 34))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "#988AE1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Master your sleep schedule.")
                        .font(.appRegular(size: 17))
                        .opacity(0.75)
                        .foregroundStyle(.white)
                }

                VStack(spacing: 22) {
                    Button {
                        path.append(AppRoute.onboarding)
                    } label: {
                        Text("Get started")
                    }
                    .style(.primary)

                    HStack(spacing: 0) {
                        Text("Already have an account? - ")
                            .font(.appRegular16)

                        Button {
                            path.append(AppRoute.login)
                        } label: {
                            Text("Login")
                                .font(.appMedium16)
                                .underline()
                        }
                    }
                }
                .foregroundStyle(.white)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.vertical, 50)
            .padding(.horizontal, 52)
        }
    }
}

#Preview {
    SplashView()
}

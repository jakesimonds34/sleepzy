//
//  SplashView.swift
//  Sleepzy
//

import SwiftUI

// MARK: - PendingSignup
struct PendingSignup: Hashable {
    let fullName: String
    let email: String
    let password: String
}

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    case onboarding
    case login
    case signup(profile: Profile?)
    case onboardingForSignup(pending: PendingSignup)
    case forgotPassword
}

extension Profile: Hashable {
    public static func == (lhs: Profile, rhs: Profile) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - SplashView
struct SplashView: View {
    @StateObject private var viewModel    = SplashViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var path               = NavigationPath()
    @State private var isCheckingSession  = true

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
                        OnboardingView(path: $path, pendingSignup: pending)
                    case .forgotPassword:
                        ForgotPasswordView()
                    }
                }
                .ignoresSafeArea()
                .navigationBarHidden(true)
        }
        // ✅ تحقق من الـ session عند فتح التطبيق
        .task {
            await authViewModel.loadSession()
            isCheckingSession = false
        }
    }

    @ViewBuilder
    private var content: some View {
        // إذا كان يتحقق من الـ session → اعرض loading
        if isCheckingSession {
            ZStack {
                MyImage(source: .asset(.bgSplash))
                    .scaledToFill()
                    .ignoresSafeArea()

                MyImage(source: .asset(.logoSplash))
                    .scaledToFit()
                    .frame(width: 277)
            }
        } else {
            // انتهى التحقق → اعرض Splash العادي (إذا لم يكن مسجلاً)
            splashContent
        }
    }

    private var splashContent: some View {
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

//
//  EnterCodeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct EnterCodeView: View {
    // MARK: - Properties
    @StateObject var viewModel = AuthViewModel()
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bg))
                    .scaledToFill()
            )
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showNewPassword) {
                NewPasswordView()
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        GeometryReader { geo in
            VStack(spacing: 44) {
                AppHeaderView(title: "Enter Code",
                              subTitle: "Enter the code we sent to your email",
                              isBack: true)
                .padding(.bottom, 14)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("CODE")
                        .font(.appRegular(size: 11))
                        .foregroundStyle(.white)
                    
                    AEOTPView(
                        text: $viewModel.verificationCode,
                        slotsCount: viewModel.otpLength,
                        width: geo.size.width,
                        height: 56,
                        otpDefaultCharacter: "",
                        otpBackgroundColor: .white.withAlphaComponent(0.03),
                        otpFilledBackgroundColor: .white.withAlphaComponent(0.03),
                        otpCornerRaduis: 10,
                        otpDefaultBorderColor: UIColor.white.withAlphaComponent(0.2),
                        otpFilledBorderColor: .white,
                        otpDefaultBorderWidth: 1,
                        otpFilledBorderWidth: 1,
                        otpTextColor: .white,
                        otpFontSize: 22,
                        otpFont: .systemFont(ofSize: 22, weight: .bold),
                        isSecureTextEntry: false,
                        enableClearOTP: true) {
                            // On Commit
                            // submitAction()
                        }
                        .environment(\.layoutDirection, .leftToRight)
                        .environment(\.locale, Language.english.locale)
                }
                
                Spacer()
                
                Button {
                    viewModel.showNewPassword.toggle()
                } label: {
                    Text("Proceed")
                }
                .style(.primary)
                .padding(.bottom, 92)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    EnterCodeView()
}

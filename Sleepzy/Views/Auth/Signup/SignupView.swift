//
//  SignupView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct SignupView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = AuthViewModel()
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bg))
                    .scaledToFill()
            )
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .navigationDestination(isPresented: $viewModel.showOnboarding) {
                OnboardingView()
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 44) {
            AppHeaderView(title: "Sign Up",
                          subTitle: "Create an account with your details.",
                          isBack: true)
            .padding(.bottom, 14)
            
            TextFieldFormView(
                title: "FULL NAME",
                placeholder: "Your full name",
                trailingImage: .user,
                value: $viewModel.fullName,
                isMandatory: true,
                type: .text
            )
            
            TextFieldFormView(
                title: "EMAIL ADDRESS",
                placeholder: "Your email address",
                trailingImage: .envelope,
                value: $viewModel.email,
                isMandatory: true,
                type: .email
            )
            
            TextFieldFormView(
                title: "PASSWORD",
                placeholder: "*******",
                value: $viewModel.password,
                isMandatory: true,
                type: .password
            )
            
            TextFieldFormView(
                title: "CONFIRM PASSWORD",
                placeholder: "*******",
                value: $viewModel.confirmPassword,
                isMandatory: true,
                type: .password
            )
            
            Spacer()
            
            VStack(spacing: 22) {
                Button {
                    guard !viewModel.isLoading else { return }
                    Task {
                        await viewModel.signUp(
                            fullName: viewModel.fullName,
                            email: viewModel.email,
                            password: viewModel.password
                        )
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Create an account")
                    }
                }
                .style(.primary)
                
                HStack(spacing: 0) {
                    Text("Already have an account? - ")
                        .font(.appRegular16)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Login")
                            .font(.appMedium16)
                            .underline()
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignupView()
}

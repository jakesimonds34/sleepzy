//
//  ForgotPasswordView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
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
            .navigationDestination(isPresented: $viewModel.showEnterCode) {
                EnterCodeView()
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 44) {
            AppHeaderView(title: "Forgot Password",
                          subTitle: "Enter your email to receive a reset code.",
                          isBack: true)
            .padding(.bottom, 14)
            
            TextFieldFormView(
                title: "EMAIL ADDRESS",
                placeholder: "Your email address",
                trailingImage: .envelope,
                value: $viewModel.email,
                isMandatory: true,
                type: .email
            )
            
            Spacer()
            
            Button {
//                viewModel.showEnterCode.toggle()
                Task {
                    await viewModel.forgotPassword(email: viewModel.email)
                }
            } label: {
                Text("Send Code")
            }
            .style(.primary)
            .padding(.bottom, 92)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ForgotPasswordView()
}

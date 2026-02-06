//
//  ForgotPasswordView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - Properties
    @StateObject var viewModel = LoginViewModel()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            MyImage(source: .asset(.bg))
                .scaledToFill()
            
            content
        }
        .ignoresSafeArea()
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
                type: .text
            )
            
            Spacer()
            
            Button {
                
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

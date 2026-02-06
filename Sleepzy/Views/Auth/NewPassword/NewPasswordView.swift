//
//  NewPasswordView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct NewPasswordView: View {
    // MARK: - Properties
    @StateObject var viewModel = NewPasswordViewModel()
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bg))
                    .scaledToFill()
            )
            .ignoresSafeArea()
            .navigationBarHidden(true)
//            .navigationDestination(isPresented: $viewModel.showNewPassword) {
//                NewPasswordView()
//            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 44) {
            AppHeaderView(title: "New Password",
                          subTitle: "Set a new password for Sleepzy.",
                          isBack: true)
            .padding(.bottom, 14)
            
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
            
            Button {
                
            } label: {
                Text("Proceed")
            }
            .style(.primary)
            .padding(.bottom, 92)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NewPasswordView()
}

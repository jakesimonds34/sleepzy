//
//  LoginView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct LoginView: View {
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
            AppHeaderView(title: "Hello! Adam 👋🏻",
                          subTitle: "Welcome back. Please login",
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
            
            VStack(spacing: 16) {
                TextFieldFormView(
                    title: "PASSWORD",
                    placeholder: "*******",
                    value: $viewModel.password,
                    isMandatory: true,
                    type: .password
                )
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("Forget Password")
                            .underline()
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack(spacing: 22) {
                Button {
                    
                } label: {
                    Text("Login")
                }
                .style(.primary)
                
                HStack(spacing: 0) {
                    Text("Don’t have an account? - ")
                        .font(.appRegular16)
                    
                    Button {
                        
                    } label: {
                        Text("Signup")
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
    LoginView()
}

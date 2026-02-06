//
//  SplashView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 05/02/2026.
//

import SwiftUI

struct SplashView: View {
    // MARK: - Properties
    
    // MARK: - Body
    var body: some View {
        content
            .ignoresSafeArea()
    }
    
    // MARK: - View Components
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
                }
                
                VStack(spacing: 22) {
                    Button {
                        
                    } label: {
                        Text("Get started")
                    }
                    .style(.primary)
                    
                    HStack(spacing: 0) {
                        Text("Already have an account? - ")
                            .font(.appRegular16)
                        
                        Button {
                            
                        } label: {
                            Text("Login")
                                .font(.appMedium16)
                                .underline()
                        }
                        
                    }
                }
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

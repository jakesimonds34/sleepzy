//
//  EnterCodeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct EnterCodeView: View {
    // MARK: - Properties
    @StateObject var viewModel = EnterCodeViewModel()
    
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
            AppHeaderView(title: "Enter Code",
                          subTitle: "Enter the code we sent to your email",
                          isBack: true)
            .padding(.bottom, 14)
            
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
    EnterCodeView()
}

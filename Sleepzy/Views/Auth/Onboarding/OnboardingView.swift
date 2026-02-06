//
//  OnboardingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - Properties
    @State private var currentStep = 0.1
    
    // MARK: - Body
    var body: some View {
        ZStack {
            MyImage(source: .asset(.bg))
                .scaledToFill()
                .ignoresSafeArea()
            
            content
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            ProgressView(value: currentStep, total: 0.5)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#5939A8")))
                .frame(height: 6)
                .padding(.horizontal)
            
            ScrollView {
                switch currentStep {
                case 0.1:
                    GoalView(currentStep: $currentStep)
                case 0.2:
                    SleepScheduleView(currentStep: $currentStep)
                default:
                    Text("")
                }
            }
        }
        .padding(.top, 85)
    }
}

#Preview {
    OnboardingView()
}

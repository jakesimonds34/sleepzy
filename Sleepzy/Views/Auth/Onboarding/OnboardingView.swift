//
//  OnboardingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - Properties
    @State private var currentStep: Double = 1
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bg))
                    .scaledToFill()
            )
            .ignoresSafeArea()
            .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            
            progressBarView()
            
            ScrollView {
                switch currentStep {
                case 1:
                    GoalView(currentStep: $currentStep)
                case 2:
                    SleepScheduleView(currentStep: $currentStep)
                case 3:
                    BiggestDistractionView(currentStep: $currentStep)
                case 4:
                    AgeView(currentStep: $currentStep)
                case 5:
                    GenderView(currentStep: $currentStep)
                default:
                    Text("")
                }
            }
            
            Button {
                if currentStep < 5 { currentStep += 1 }
            } label: {
                Text("Next")
            }
            .style(.primary)
            .padding(.horizontal, 52)

        }
        .padding(.vertical, 90)
    }
    
    @ViewBuilder
    private func progressBarView() -> some View {
        HStack {
            if currentStep > 1 {
                Button {
                    currentStep -= 1
                } label: {
                    MyImage(source: .system("arrow.backward"))
                        .scaledToFit()
                        .frame(width: 18)
                        .foregroundStyle(.white)
                }

            }
            
            ProgressView(value: Double(currentStep/10), total: 0.5)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#5939A8")))
                .frame(height: 6)
            
            Text("\(Int(currentStep))/5")
                .foregroundStyle(.white.opacity(0.75))
                .font(.appRegular(size: 17))
        }
        .padding(.horizontal)
    }
}

#Preview {
    OnboardingView()
}

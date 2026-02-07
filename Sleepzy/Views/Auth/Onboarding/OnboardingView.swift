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
    
    @State private var selectedGoal: String? = nil
    @State private var selectedDistraction: String? = nil
    @State private var selectedAge: String? = nil
    @State private var selectedGender: String? = nil
    
    private var isStepValid: Bool {
        switch currentStep {
        case 1: return selectedGoal != nil
        case 3: return selectedDistraction != nil
        case 4: return selectedAge != nil
        case 5: return selectedGender != nil
        default: return true
        }
    }
    
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
                    GoalView(currentStep: $currentStep, selectedGoal: $selectedGoal)
                case 2:
                    SleepScheduleView(currentStep: $currentStep)
                case 3:
                    BiggestDistractionView(currentStep: $currentStep, selectedDistraction: $selectedDistraction)
                case 4:
                    AgeView(currentStep: $currentStep, selectedAge: $selectedAge)
                case 5:
                    GenderView(currentStep: $currentStep, selectedGender: $selectedGender)
                default:
                    Text("")
                }
            }
            
            Button {
                if currentStep < 5 {
                    currentStep += 1
                } else {
                    AppEnvironment.shared.appStatus = .home
                }
            } label: {
                Text("Next")
            }
            .style(.primary)
            .padding(.horizontal, 52)
            .disabled(!isStepValid)
            .opacity(isStepValid ? 1 : 0.5)

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

//
//  OnboardingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI
import FamilyControls

// MARK: - OnboardingView
struct OnboardingView: View {
    @StateObject var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStepIndex: Int = 0
    @State private var direction: Int = 1  // 1 = forward, -1 = backward
    @State private var selections: [OnboardingStep: String] = [:]
    
    private let steps = OnboardingStep.allCases
    
    private var currentStep: OnboardingStep {
        steps[currentStepIndex]
    }
    
    private var isStepValid: Bool {
        (currentStep == .sleepScore || currentStep == .potentialScore) ? true : selections[currentStep] != nil
    }
    
    var body: some View {
        VStack {
            if (currentStep == .sleepScore) || (currentStep == .potentialScore) {
                backButtonOnly
            } else {
                progressBarView
            }
            
            // ✅ Animation عند الانتقال
            ZStack {
                stepView(for: currentStep)
                    .id(currentStepIndex)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: direction > 0 ? .trailing : .leading)
                                .combined(with: .opacity),
                            removal: .move(edge: direction > 0 ? .leading : .trailing)
                                .combined(with: .opacity)
                        )
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button {
                goToNext()
            } label: {
                Text((currentStep == .sleepScore) || (currentStep == .potentialScore) ? "Continue" : "Next")
            }
            .style(.primary)
            .padding(.horizontal, 52)
            .disabled(!isStepValid)
            .opacity(isStepValid ? 1 : 0.5)
        }
        .padding(.vertical, 90)
        .background(
            MyImage(source: .asset(.bg)).scaledToFill()
        )
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.showSignup) {
            SignupView(profile: viewModel.profile ?? Profile(id: UUID(), fullName: ""))
        }
    }
    
    // MARK: - Step View Builder
    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        ScrollView(showsIndicators: false) {
            if step == .sleepScore {
                SleepScoreView(
                    title: "Your current sleep score",
                    image: .scoreProgress, heightImage: 172,
                    issues: LocalData.SleepScore.items,
                    footerNote: "Your current habits maybe affecting your rest"
                )
            } else if step == .potentialScore {
                SleepScoreView(
                    title: "Your Potential Score",
                    image: .scoreChart, heightImage: 234,
                    issues: LocalData.PotentialScore.items,
                    footerNote: "Sleepzy can help you enjoy way better rest."
                )
            } else {
                OnboardingStepView(
                    data: step,
                    selectedValue: Binding(
                        get: { selections[step] },
                        set: { selections[step] = $0 }
                    )
                )
            }
        }
    }
    
    // MARK: - Navigation
    private func goToNext() {
        if currentStepIndex < steps.count - 1 {
            direction = 1
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStepIndex += 1
            }
        } else {
            let profile = Profile(
                id: UUID(),
                fullName: viewModel.fullName,
                email: viewModel.email,
                createdAt: Date(),
                goal: selections[.goal],
                biggestDistraction: selections[.distraction],
                ageRange: selections[.age],
                gender: selections[.gender],
                stayAsleep: selections[.stayAsleep],
                earlyWakeupRating: selections[.earlyWakeup],
                dailyFunctionInterference: selections[.dailyFunction]
            )
            viewModel.profile = profile
            viewModel.showSignup.toggle()
        }
    }
    
    private func goBack() {
        guard currentStepIndex > 0 else { return }
        direction = -1
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStepIndex -= 1
        }
    }

    // MARK: - Progress Bar
    private var progressBarView: some View {
        let normalSteps = steps.filter { ($0 != .sleepScore) || ($0 != .potentialScore) }
        let normalIndex = normalSteps.firstIndex(of: currentStep) ?? 0
        
        return HStack {
            if currentStepIndex > 0 {
                Button { goBack() } label: {
                    MyImage(source: .system("arrow.backward"))
                        .scaledToFit()
                        .frame(width: 18)
                        .foregroundStyle(.white)
                }
            }
            
            ProgressView(
                value: Double(normalIndex + 1),
                total: Double(normalSteps.count - 2)
            )
            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#5939A8")))
            .frame(height: 6)
            .animation(.easeInOut(duration: 0.4), value: normalIndex)
            
            Text("\(normalIndex + 1)/\(normalSteps.count - 2)")
                .foregroundStyle(.white.opacity(0.75))
                .font(.appRegular(size: 17))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Back Button Only
    private var backButtonOnly: some View {
        HStack {
            Button { goBack() } label: {
                MyImage(source: .system("arrow.backward"))
                    .scaledToFit()
                    .frame(width: 18)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    OnboardingView()
}

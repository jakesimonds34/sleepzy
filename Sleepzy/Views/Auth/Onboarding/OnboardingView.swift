//
//  OnboardingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI
import FamilyControls

/*
struct OnboardingView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: ScreenTimeAuthorizationManager
    @EnvironmentObject var appSelection: AppSelectionManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = AuthViewModel()
    
    @State private var currentStep: Double = 1
    
    @State private var selectedGoal: String? = nil
    @State private var bedHour: Double = 22     // 10 PM
    @State private var wakeHour: Double = 8     // 8 AM
    @State private var selectedBiggestDistraction: String? = nil
    @State private var selectedAge: String? = nil
    @State private var selectedGender: String? = nil
    @State private var selectedStayAsleep: String? = nil
    @State private var selectedEarlyWakeupRating: String? = nil
    @State private var selectedDailyFunction: String? = nil
    @State private var selectedDistractingApps: String? = nil
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    @State private var repeatModel: RepeatDaysModel = RepeatDaysModel()
    
    @State private var showPicker: Bool = false
    
    var sleepTime: Double {
        let diff = wakeHour - bedHour
        return diff >= 0 ? diff : (24 + diff)
    }
    
    private var isStepValid: Bool {
        switch currentStep {
        case 1: return selectedGoal != nil
        case 3: return selectedBiggestDistraction != nil
        case 4: return selectedAge != nil
        case 5: return selectedGender != nil
        case 6: return selectedStayAsleep != nil
        case 7: return selectedEarlyWakeupRating != nil
        case 8: return selectedDailyFunction != nil
        case 9: return !appSelection.selection.applicationTokens.isEmpty || !appSelection.selection.categoryTokens.isEmpty
        case 10: return true
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
            .navigationDestination(isPresented: $viewModel.showSignup) {
                SignupView(profile: viewModel.profile ?? Profile(id: UUID(), fullName: ""))
            }
            .sheet(isPresented: $showPicker) {
                if authManager.isAuthorized {
                    FamilyActivityPicker(selection: $appSelection.selection)
                } else {
                    Text("Screen Time permission must be granted first")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
                    SleepScheduleView(currentStep: $currentStep, bedHour: $bedHour, wakeHour: $wakeHour)
                case 3:
                    BiggestDistractionView(currentStep: $currentStep, selectedDistraction: $selectedBiggestDistraction)
                case 4:
                    AgeView(currentStep: $currentStep, selectedAge: $selectedAge)
                case 5:
                    GenderView(currentStep: $currentStep, selectedGender: $selectedGender)
                case 6:
                    StayAsleepView(currentStep: $currentStep, selectedStayAsleep: $selectedStayAsleep)
                case 7:
                    EarlyWakeupRatingView(currentStep: $currentStep, selectedEarlyWakeupRating: $selectedEarlyWakeupRating)
                case 8:
                    DailyFunctionView(currentStep: $currentStep, selectedDailyFunction: $selectedDailyFunction)
                case 9:
                    DistractingAppsView(currentStep: $currentStep, selectedDistractingApps: $selectedDistractingApps)
                case 10:
                    FocusProtectionScheduleView(
                        repeatModel: $repeatModel,
                        currentStep: $currentStep,
                        fromTime: $selectedFromTime,
                        toTime: $selectedToTime
                    )
                default:
                    Text("")
                }
            }
            
            Button {
                if currentStep < 10 {
                    currentStep += 1
                } else {
                    // AppEnvironment.shared.appStatus = .home
                    let profile = Profile(
                        id: UUID(),
                        fullName: "",
                        createdAt: Date(),
                        ageRange: selectedAge,
                        gender: selectedGender,
                        email: "",
                        goal: selectedGoal,
                        biggestDistraction: selectedBiggestDistraction,
                        stayAsleep: selectedStayAsleep,
                        earlyWakeupRating: selectedEarlyWakeupRating,
                        dailyFunctionInterference: selectedDailyFunction,
                        distractingApps: selectedDistractingApps,
                        focusProtectionRepeatOn: repeatDaysToJSON(repeatModel.selected),
                        sleepTime: sleepTime.rounded(toDecimalPlaces: 2),
                        wakeUp: wakeHour.rounded(toDecimalPlaces: 2),
                        bedTime: bedHour.rounded(toDecimalPlaces: 2),
                        focusProtectionFrom: selectedFromTime,
                        focusProtectionTo: selectedToTime
                    )
                    
                    viewModel.profile = profile
                    viewModel.showSignup.toggle()
                }
                
                print(selectedGoal ?? "")
                print(bedHour)
                print(wakeHour)
                print(sleepTime)
                print(selectedBiggestDistraction ?? "")
                print(selectedAge ?? "")
                print(selectedGender ?? "")
                print(selectedStayAsleep ?? "")
                print(selectedEarlyWakeupRating ?? "")
                print(selectedDailyFunction ?? "")
                print(selectedDistractingApps ?? "")
                print(selectedFromTime)
                print(selectedToTime)
                print(repeatModel.selected)
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
            
            ProgressView(value: Double(currentStep/10), total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#5939A8")))
                .frame(height: 6)
            
            Text("\(Int(currentStep))/10")
                .foregroundStyle(.white.opacity(0.75))
                .font(.appRegular(size: 17))
        }
        .padding(.horizontal)
    }
}
*/

// MARK: - OnboardingView
struct OnboardingView: View {
    @StateObject var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStepIndex: Int = 0
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
            
            ScrollView {
                if currentStep == .sleepScore {
                    SleepScoreView(
                        title: "Your current sleep score",
                        image: .scoreProgress, heightImage: 172,
                        issues: LocalData.SleepScore.items,
                        footerNote: "Your current habits maybe affecting your rest"
                    )
                } else if currentStep == .potentialScore {
                    SleepScoreView(
                        title: "Your Potential Score",
                        image: .scoreChart, heightImage: 234,
                        issues: LocalData.PotentialScore.items,
                        footerNote: "Sleepzy can help you enjoy way better rest."
                    )
                } else {
                    OnboardingStepView(
                        data: currentStep,
                        selectedValue: Binding(
                            get: { selections[currentStep] },
                            set: { selections[currentStep] = $0 }
                        )
                    )
                }
            }
            
            Button {
                if currentStepIndex < steps.count - 1 {
                    currentStepIndex += 1
                } else {
                    AppEnvironment.shared.appStatus = .home
                }
            } label: {
                Text((currentStep == .sleepScore) || (currentStep == .potentialScore) ? "Continue " : "Next")
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
    
    // MARK: - Progress Bar (for normal steps)
    private var progressBarView: some View {
        let normalSteps = steps.filter { ($0 != .sleepScore) || ($0 != .potentialScore) }
        let normalIndex = normalSteps.firstIndex(of: currentStep) ?? 0
        
        return HStack {
            if currentStepIndex > 0 {
                Button { currentStepIndex -= 1 } label: {
                    MyImage(source: .system("arrow.backward"))
                        .scaledToFit()
                        .frame(width: 18)
                        .foregroundStyle(.white)
                }
            }
            
            ProgressView(
                value: Double(normalIndex + 1),
                total: Double(normalSteps.count-2)
            )
            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#5939A8")))
            .frame(height: 6)
            
            Text("\(normalIndex + 1)/\(normalSteps.count-2)")
                .foregroundStyle(.white.opacity(0.75))
                .font(.appRegular(size: 17))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Back Button Only (for sleepScore step)
        private var backButtonOnly: some View {
            HStack {
                Button { currentStepIndex -= 1 } label: {
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

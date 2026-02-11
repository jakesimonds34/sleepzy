//
//  OnboardingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - Properties
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
        case 9: return selectedDistractingApps != nil
        case 10: return selectedDistractingApps != nil
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
                        bedTime: bedHour,
                        sleepTime: sleepTime,
                        wakeUp: wakeHour,
                        biggestDistraction: selectedBiggestDistraction,
                        stayAsleep: selectedStayAsleep,
                        earlyWakeupRating: selectedEarlyWakeupRating,
                        dailyFunctionInterference: selectedDailyFunction,
                        distractingApps: selectedDistractingApps,
                        focusProtectionFrom: selectedFromTime,
                        focusProtectionTo: selectedToTime)
                    
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

#Preview {
    OnboardingView()
}

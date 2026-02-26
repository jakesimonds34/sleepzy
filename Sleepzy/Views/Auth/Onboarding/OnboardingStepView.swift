//
//  OnboardingStepView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 26/02/2026.
//

import SwiftUI

// MARK: - Protocol
protocol OnboardingStepData {
    var items: [RowItem] { get }
    var title: String { get }
    var subTitle: String { get }
}

struct RowItem {
    var icon: ImageResource?
    var title: String
}

// MARK: - Generic Onboarding Step View
struct OnboardingStepView: View {
    let data: any OnboardingStepData
    @Binding var selectedValue: String?
    
    var body: some View {
        VStack {
            AppHeaderView(
                title: data.title,
                subTitle: data.subTitle,
                isBack: false,
                paddingTop: 16
            )
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(data.items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedValue == item.title)
                        .onTapGesture {
                            selectedValue = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct RowItemView: View {
    var item: RowItem
    var isSelected: Bool
    
    var body: some View {
        HStack {
            if let icon = item.icon {
                MyImage(source: .asset(icon))
                    .scaledToFit()
                    .frame(width: 20)
            }
            
            Text(item.title)
                .foregroundColor(.white)
                .font(.appRegular16)
            
            Spacer()
            
            if isSelected {
                MyImage(source: .asset(.checkIcon))
                    .frame(width: 12, height: 12)
                    .font(.appBold20)
                    .foregroundStyle(.white)
                    .frame(width: 16, height: 16)
                    .background(Color(hex: "5939A8"))
                    .cornerRadius(8)
            } else {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.white.opacity(0.2))
            }
        }
        .padding()
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(isSelected ? Color(hex: "5939A8").opacity(0.1) : Color.clear)
                .stroke(
                    isSelected ? Color(hex: "988AE1").opacity(0.8) : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Step Definitions
enum OnboardingStep: CaseIterable {
    case goal, distraction, age, gender, stayAsleep, earlyWakeup, dailyFunction
}

extension OnboardingStep: OnboardingStepData {
    var title: String {
        switch self {
        case .goal:         return "What's your goal?"
        case .distraction:  return "What is your biggest distraction?"
        case .age:          return "How old are you?"
        case .gender:       return "What's your gender?"
        case .stayAsleep:   return "How difficult is it for you to stay asleep?"
        case .earlyWakeup:  return "Rate your problem with waking up too early?"
        case .dailyFunction: return "How does poor sleep affect your daily function?"
        }
    }
    
    var subTitle: String {
        switch self {
        case .goal: return "We'll tailor the experience to your needs."
        default:    return ""
        }
    }
    
    var items: [RowItem] {
        switch self {
        case .goal:          return LocalData.Goals.items
        case .distraction:   return LocalData.Distractions.items
        case .age:           return LocalData.Ages.items
        case .gender:        return LocalData.Gender.items
        case .stayAsleep:    return LocalData.StayAsleep.items
        case .earlyWakeup:   return LocalData.EarlyWakeupRating.items
        case .dailyFunction: return LocalData.DailyFunction.items
        }
    }
}

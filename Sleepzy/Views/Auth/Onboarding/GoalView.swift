//
//  GoalView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct RowItem {
    var icon: ImageResource?
    var title: String
}

struct GoalView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var selectedGoal: String?
    
    let goals: [RowItem] = [
        RowItem(icon: .sleepIcon, title: "Fall asleep faster"),
        RowItem(icon: .pillowIcon, title: "Stay asleep longer"),
        RowItem(icon: .wakeUpIcon, title: "Wake up refreshed"),
        RowItem(icon: .timeIcon, title: "Reduce screen time")
    ]
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "What’s your goal?",
                          subTitle: "We'll tailor the experience to your needs.",
                          isBack: false)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(goals, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedGoal == item.title)
                        .onTapGesture {
                            selectedGoal = item.title
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

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedGoal: String? = ""
    GoalView(currentStep: $currentStep, selectedGoal: $selectedGoal)
}

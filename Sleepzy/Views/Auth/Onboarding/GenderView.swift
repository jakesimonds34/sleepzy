//
//  GenderView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct GenderView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @State private var selectedGoal: String? = nil
    
    let items: [RowItem] = [
        RowItem(title: "Female"),
        RowItem(title: "Male"),
        RowItem(title: "Other"),
        RowItem(title: "Prefer not to say")
    ]
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "What’s your gender?",
                          subTitle: "",
                          isBack: false)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
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

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    GenderView(currentStep: $currentStep)
}

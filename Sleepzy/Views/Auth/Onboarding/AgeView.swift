//
//  AgeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct AgeView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @State private var selectedGoal: String? = nil
    
    let items: [RowItem] = [
        RowItem(title: "10-17"),
        RowItem(title: "18-24"),
        RowItem(title: "25-34"),
        RowItem(title: "35-44"),
        RowItem(title: "45+")
    ]
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "How old are you?",
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
    AgeView(currentStep: $currentStep)
}

//
//  BiggestDistractionView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct BiggestDistractionView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var selectedDistraction: String?
    
    let items = LocalData.Distractions.items
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "What is your biggest distraction?",
                          subTitle: "",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedDistraction == item.title)
                        .onTapGesture {
                            selectedDistraction = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedDistraction: String? = ""
    BiggestDistractionView(currentStep: $currentStep, selectedDistraction: $selectedDistraction)
}

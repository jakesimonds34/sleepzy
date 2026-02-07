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
    
    let items: [RowItem] = [
        RowItem(icon: .socialMediaIcon, title: "Social media scrolling"),
        RowItem(icon: .laptopIcon, title: "Late night work"),
        RowItem(icon: .brainIcon, title: "Overactive thinking"),
        RowItem(icon: .hearIcon, title: "Environmental noises ")
    ]
    
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
                          isBack: false)
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

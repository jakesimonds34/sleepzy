//
//  StayAsleepView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI

struct StayAsleepView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var selectedStayAsleep: String?
    
    let items = LocalData.StayAsleep.items
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "How difficult is it for you to stay asleep?",
                          subTitle: "",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedStayAsleep == item.title)
                        .onTapGesture {
                            selectedStayAsleep = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedStayAsleep: String? = ""
    StayAsleepView(currentStep: $currentStep, selectedStayAsleep: $selectedStayAsleep)
}

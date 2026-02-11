//
//  EarlyWakeupRatingView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI

struct EarlyWakeupRatingView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var selectedEarlyWakeupRating: String?
    
    let items = LocalData.EarlyWakeupRating.items
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "Rate your problem with waking up too early?",
                          subTitle: "",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedEarlyWakeupRating == item.title)
                        .onTapGesture {
                            selectedEarlyWakeupRating = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedEarlyWakeupRating: String? = ""
    EarlyWakeupRatingView(currentStep: $currentStep, selectedEarlyWakeupRating: $selectedEarlyWakeupRating)
}

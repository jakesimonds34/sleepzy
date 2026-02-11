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
    @Binding var selectedAge: String?
    
    let items = LocalData.Ages.items
    
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
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedAge == item.title)
                        .onTapGesture {
                            selectedAge = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedAge: String? = ""
    AgeView(currentStep: $currentStep, selectedAge: $selectedAge)
}

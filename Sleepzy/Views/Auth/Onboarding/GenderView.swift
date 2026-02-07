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
    @Binding var selectedGender: String?
    
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
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedGender == item.title)
                        .onTapGesture {
                            selectedGender = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedGender: String? = ""
    GenderView(currentStep: $currentStep, selectedGender: $selectedGender)
}

//
//  DistractingAppsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI

struct DistractingAppsView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var selectedDistractingApps: String?
    
    let items: [RowItem] = [
        RowItem(title: "Not at all"),
        RowItem(title: "Barely"),
        RowItem(title: "Somewhat"),
        RowItem(title: "Much"),
        RowItem(title: "Very much interfering")
    ]
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "Which apps usually keep you awake?",
                          subTitle: "Select apps you want Sleepzy to block at night",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(items, id: \.title) { item in
                    RowItemView(item: item, isSelected: selectedDistractingApps == item.title)
                        .onTapGesture {
                            selectedDistractingApps = item.title
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedDistractingApps: String? = ""
    DistractingAppsView(currentStep: $currentStep, selectedDistractingApps: $selectedDistractingApps)
}

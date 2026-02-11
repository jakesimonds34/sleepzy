//
//  DistractingAppsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI
import FamilyControls

struct DistractingAppsView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: ScreenTimeAuthorizationManager
    @EnvironmentObject var appSelection: AppSelectionManager
    
    @Binding var currentStep: Double
    @Binding var selectedDistractingApps: String?
    
    let items = LocalData.DistractingApps.items
    
    // MARK: - Body
    var body: some View {
        content
            .task {
                await authManager.requestAuthorization()
            }
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
                
                ForEach(Array(appSelection.selection.applicationTokens), id: \.self) { token in
                    RowItemView(item: RowItem(title: token.), isSelected: <#T##Bool#>)
//                    let item = RowItem(title: token.localizedDisplayName)
//                    RowItemView(item: item, isSelected: selectedDistractingApps == item.title)
//                        .onTapGesture {
//                            selectedDistractingApps = item.title
//                        }
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

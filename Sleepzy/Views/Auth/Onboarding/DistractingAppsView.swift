//
//  DistractingAppsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - Main View
struct DistractingAppsView: View {
    @EnvironmentObject var authManager: ScreenTimeAuthorizationManager
    @EnvironmentObject var appSelection: AppSelectionManager
    @State private var isPresented = false
    
    @Binding var currentStep: Double
    @Binding var selectedDistractingApps: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Apps List
            if !appSelection.selection.applicationTokens.isEmpty || !appSelection.selection.categoryTokens.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        selectedAppsSection
                        selectedCategoriesSection
                    }
                    .padding()
                }
            } else {
                emptyStateView
            }
        }
        .task {
            await authManager.requestAuthorization()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
        .familyActivityPicker(
            isPresented: $isPresented,
            selection: $appSelection.selection
        )
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 0) {
                AppHeaderView(title: "Which apps usually keep you awake?",
                              subTitle: "Select apps you want Sleepzy to block at night",
                              isBack: false,
                              paddingTop: 16)
                addButton
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "apps.iphone")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Managed Applications")
                        .font(.headline)
                    Text("\(appSelection.selection.applicationTokens.count) selected application")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            
            Divider()
        }
    }
    
    // MARK: - Selected Apps Section
    private var selectedAppsSection: some View {
        Group {
            if !appSelection.selection.applicationTokens.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Applications")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    
                    ForEach(Array(appSelection.selection.applicationTokens.enumerated()), id: \.element) { index, token in
                        AppTokenCard(token: token, index: index) {
                            removeApp(token)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Selected Categories Section
    private var selectedCategoriesSection: some View {
        Group {
            if !appSelection.selection.categoryTokens.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categories")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    
                    ForEach(Array(appSelection.selection.categoryTokens.enumerated()), id: \.element) { index, token in
                        CategoryTokenCard(token: token, index: index) {
                            removeCategory(token)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Apps Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the '+' button to add the apps you want to manage")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { isPresented = true }) {
                Label("Select Apps", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "5939A8"))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button(action: { isPresented = true }) {
            Image(systemName: "plus")
                .font(.title3)
        }
        .padding(.top, 25)
    }
    
    // MARK: - Actions
    private func removeApp(_ token: ApplicationToken) {
        withAnimation {
            appSelection.selection.applicationTokens.remove(token)
        }
    }
    
    private func removeCategory(_ token: ActivityCategoryToken) {
        withAnimation {
            appSelection.selection.categoryTokens.remove(token)
        }
    }
}

// MARK: - App Token Card
struct AppTokenCard: View {
    let token: ApplicationToken
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // App Icon using Label
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 40, height: 40)
//                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // App Name
                Label(token)
                    .labelStyle(.titleOnly)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("application #\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.clear)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Category Token Card
struct CategoryTokenCard: View {
    let token: ActivityCategoryToken
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 40, height: 40)
//                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Category Name
                Label(token)
                    .labelStyle(.titleOnly)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("category #\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.clear)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedDistractingApps: String? = ""
    DistractingAppsView(currentStep: $currentStep, selectedDistractingApps: $selectedDistractingApps)
}

/*
struct DistractingAppsView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: ScreenTimeAuthorizationManager
//    @EnvironmentObject var appSelection: AppSelectionManager
    
    @State private var selection = FamilyActivitySelection()
    @State private var isPresented = false
    
    @Binding var currentStep: Double
    @Binding var selectedDistractingApps: String?
    
    let items = LocalData.DistractingApps.items
    
    // MARK: - Body
    var body: some View {
        content
            .task {
                await authManager.requestAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .familyActivityPicker(
                isPresented: $isPresented,
                selection: $selection
            )
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
                
                ForEach(Array(selection.applicationTokens.enumerated()), id: \.offset) { index, token in
                    AppTokenCard(token: token, index: index) {
                        removeApp(token)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button(action: { isPresented = true }) {
            Image(systemName: "plus")
                .font(.title3)
        }
    }
    
    // MARK: - Actions
    private func removeApp(_ token: ApplicationToken) {
        withAnimation {
            selection.applicationTokens.remove(token)
        }
    }
    
    private func removeCategory(_ token: ActivityCategoryToken) {
        withAnimation {
            selection.categoryTokens.remove(token)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedDistractingApps: String? = ""
    DistractingAppsView(currentStep: $currentStep, selectedDistractingApps: $selectedDistractingApps)
}
*/

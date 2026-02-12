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
    @State private var showApplySheet = false
    
    @Binding var currentStep: Double
    @Binding var selectedDistractingApps: String?
    
    // ManagedSettingsStore لتطبيق القيود
    private let store = ManagedSettingsStore()
    
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
                        
                        // زر تطبيق القيود
                        applyRestrictionsButton
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
        .sheet(isPresented: $showApplySheet) {
            ApplyRestrictionsSheet(
                appSelection: appSelection,
                onApply: { scheduleType in
                    applyRestrictions(scheduleType: scheduleType)
                }
            )
        }
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
    
    // MARK: - Apply Restrictions Button
    private var applyRestrictionsButton: some View {
        VStack(spacing: 12) {
            // معلومات توضيحية
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                Text("Tap 'Apply Block' to activate restrictions on selected apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // زر التطبيق
            Button(action: {
                showApplySheet = true
            }) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.title3)
                    
                    Text("Apply Block Schedule")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "5939A8"), Color(hex: "7B5BC4")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(appSelection.selection.applicationTokens.isEmpty &&
                     appSelection.selection.categoryTokens.isEmpty)
        }
        .padding(.top, 20)
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
    
    // MARK: - Apply Restrictions
    private func applyRestrictions(scheduleType: ScheduleType) {
        // تطبيق Shield على التطبيقات المحددة
        store.shield.applications = appSelection.selection.applicationTokens.isEmpty ?
            nil : appSelection.selection.applicationTokens
        
        // تطبيق Shield على الفئات
        if !appSelection.selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(appSelection.selection.categoryTokens)
        } else {
            store.shield.applicationCategories = nil
        }
        
        // حفظ نوع الجدولة المختار
        selectedDistractingApps = scheduleType.rawValue
        
        // عرض تنبيه نجاح
        showSuccessAlert()
    }
    
    private func showSuccessAlert() {
        // يمكنك إضافة Alert أو Toast هنا
        print("✅ Restrictions applied successfully!")
    }
}

// MARK: - Schedule Type Enum
enum ScheduleType: String, CaseIterable {
    case nightTime = "Night Time (10 PM - 7 AM)"
    case sleepTime = "Sleep Time (11 PM - 6 AM)"
    case custom = "Custom Schedule"
    case allDay = "All Day Block"
    
    var icon: String {
        switch self {
        case .nightTime: return "moon.stars.fill"
        case .sleepTime: return "bed.double.fill"
        case .custom: return "calendar.badge.clock"
        case .allDay: return "shield.fill"
        }
    }
    
    var description: String {
        switch self {
        case .nightTime:
            return "Block apps during typical night hours"
        case .sleepTime:
            return "Block apps during recommended sleep hours"
        case .custom:
            return "Set your own blocking schedule"
        case .allDay:
            return "Block apps 24/7 until you remove the restriction"
        }
    }
    
    var color: Color {
        switch self {
        case .nightTime: return .purple
        case .sleepTime: return .indigo
        case .custom: return .blue
        case .allDay: return .red
        }
    }
}

// MARK: - Apply Restrictions Sheet
struct ApplyRestrictionsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appSelection: AppSelectionManager
    @State private var selectedSchedule: ScheduleType = .nightTime
    
    let onApply: (ScheduleType) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Info
                    VStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "5939A8"))
                        
                        Text("Choose Block Schedule")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Select when you want these apps to be blocked")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Selected Apps Count
                    HStack {
                        Image(systemName: "apps.iphone")
                            .foregroundColor(.blue)
                        Text("\(appSelection.selection.applicationTokens.count) apps selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Schedule Options
                    VStack(spacing: 12) {
                        ForEach(ScheduleType.allCases, id: \.self) { schedule in
                            ScheduleOptionCard(
                                schedule: schedule,
                                isSelected: selectedSchedule == schedule,
                                onSelect: { selectedSchedule = schedule }
                            )
                        }
                    }
                    
                    // Apply Button
                    Button(action: {
                        onApply(selectedSchedule)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Apply Restrictions")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "5939A8"), Color(hex: "7B5BC4")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Block Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Schedule Option Card
struct ScheduleOptionCard: View {
    let schedule: ScheduleType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(schedule.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: schedule.icon)
                        .font(.title3)
                        .foregroundColor(schedule.color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(schedule.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? schedule.color : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? schedule.color : Color.gray.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
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


/*
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
*/
#Preview {
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var selectedDistractingApps: String? = ""
    DistractingAppsView(currentStep: $currentStep, selectedDistractingApps: $selectedDistractingApps)
}

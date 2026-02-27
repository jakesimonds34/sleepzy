//
//  SleepzyHomeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//
/*
import SwiftUI
import FamilyControls
import Combine

// MARK: - Sleepzy Home View (Updated)
struct SleepzyHomeViewUpdated: View {
    @EnvironmentObject var appSelection: AppSelectionManager
    @StateObject private var viewModel = HomeViewModelUpdated()
    @State private var showNewBlock = false
    @State private var showManageApps = false
    @State private var showBlocksList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with moon and greeting
                        headerSection
                        
                        // Active Blocks Section (NEW)
                        if !viewModel.activeBlocks.isEmpty {
                            activeBlocksSection
                        }
                        
                        // Upcoming Section
                        upcomingSection
                        
                        // Digital Shield Card
                        digitalShieldCard
                        
                        // Quick Actions (NEW)
                        quickActionsSection
                        
                        // Manage Apps Button
                        manageAppsButton
                        
                        // Add New Block Button
                        addNewBlockButton
                        
                        // Sleep Stats
                        sleepStatsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                
                // Bottom Tab Bar
                VStack {
                    Spacer()
                    customTabBar
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewBlock) {
                NavigationStack {
                    NewBlockView { configuration in
                        viewModel.addBlock(configuration)
                    }
                    .environmentObject(appSelection)
                }
            }
            .sheet(isPresented: $showManageApps) {
                NavigationStack {
                    ManageAppsView()
                }
            }
            .sheet(isPresented: $showBlocksList) {
                NavigationStack {
                    BlocksListView()
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0B2E"),
                    Color(hex: "1A1B3E"),
                    Color(hex: "0A0B2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Stars effect
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.6)
                    )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.currentDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(viewModel.greeting)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Moon image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                
                // Craters
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 15, height: 15)
                    .offset(x: -10, y: -8)
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .offset(x: 12, y: 10)
                
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 10, height: 10)
                    .offset(x: 8, y: -15)
            }
        }
        .padding(.top, 50)
    }
    
    // MARK: - Active Blocks Section (NEW)
    private var activeBlocksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Now")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.activeBlocks.count) active")
                    .font(.system(size: 13))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.activeBlocks) { block in
                        ActiveBlockMiniCard(
                            block: block,
                            onCancel: {
                                viewModel.deactivateBlock(block)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Upcoming Section
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !viewModel.upcomingBlocks.isEmpty {
                    Button(action: { showBlocksList = true }) {
                        Text("See All")
                            .font(.system(size: 13))
                            .foregroundColor(.purple)
                    }
                }
            }
            
            if viewModel.upcomingBlocks.isEmpty {
                Text("No upcoming blocks")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                ForEach(viewModel.upcomingBlocks.prefix(3)) { block in
                    UpcomingBlockCard(block: block)
                }
            }
        }
    }
    
    // MARK: - Digital Shield Card
    private var digitalShieldCard: some View {
        HStack(spacing: 16) {
            // Status Indicator
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: viewModel.shieldProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: viewModel.shieldIcon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purple)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text("Digital Shield")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(viewModel.digitalShield.status)
                        .font(.system(size: 13))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(6)
                    
                    Text(viewModel.digitalShield.timing)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Text("\(viewModel.blockedAppsCount) Apps Blocked")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Active indicator
            Circle()
                .fill(viewModel.isAnyBlockActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Quick Actions Section (NEW)
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "moon.zzz.fill",
                    title: "Night Block",
                    color: .indigo,
                    action: { viewModel.createQuickNightBlock() }
                )
                
                QuickActionCard(
                    icon: "brain.head.profile",
                    title: "Focus Time",
                    color: .orange,
                    action: { viewModel.createQuickFocusTimer() }
                )
            }
        }
    }
    
    // MARK: - Manage Apps Button
    private var manageAppsButton: some View {
        Button(action: {
            showManageApps = true
        }) {
            HStack(spacing: 12) {
                // App Icons Row
                HStack(spacing: -8) {
                    ForEach(viewModel.lockedApps.prefix(5), id: \.self) { app in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: app.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "0A0B2E"), lineWidth: 2)
                            )
                    }
                    
                    if viewModel.lockedApps.count > 5 {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("+\(viewModel.lockedApps.count - 5)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "0A0B2E"), lineWidth: 2)
                            )
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Manage Apps")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.blockedAppsCount) blocked")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Add New Block Button
    private var addNewBlockButton: some View {
        Button(action: {
            showNewBlock = true
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                
                Text("Create New Block")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
    
    // MARK: - Sleep Stats Section
    private var sleepStatsSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 14))
                .foregroundColor(.purple)
            
            Text("Sleep Last Night")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                
                Text(viewModel.sleepDuration)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: viewModel.selectedTab == .home,
                action: { viewModel.selectedTab = .home }
            )
            
            TabBarButton(
                icon: "square.stack.3d.up.fill",
                title: "Blocks",
                isSelected: viewModel.selectedTab == .sleepLog,
                action: {
                    viewModel.selectedTab = .sleepLog
                    showBlocksList = true
                }
            )
            
            TabBarButton(
                icon: "app.badge",
                title: "Apps",
                isSelected: false,
                action: { showManageApps = true }
            )
            
            TabBarButton(
                icon: "bell.fill",
                title: "Alarm",
                isSelected: viewModel.selectedTab == .alarm,
                action: { viewModel.selectedTab = .alarm }
            )
            
            TabBarButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: viewModel.selectedTab == .settings,
                action: { viewModel.selectedTab = .settings }
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 34)
        .background(
            Rectangle()
                .fill(Color(hex: "0A0B2E"))
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        )
    }
}

// MARK: - Active Block Mini Card (NEW)
struct ActiveBlockMiniCard: View {
    let block: SavedBlock
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: block.typeIcon)
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Text(block.displayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            if block.configuration.type == .timer {
                Text("Timer active")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Text(block.configuration.timeRange)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Quick Action Card (NEW)
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview
#Preview {
    SleepzyHomeViewUpdated()
        .environmentObject(AppSelectionManager.shared)
}
*/

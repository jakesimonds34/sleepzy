//
//  BlocksListView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI
import FamilyControls

// MARK: - Blocks List View
struct BlocksListView: View {
    @StateObject private var viewModel = BlocksListViewModel()
    @State private var showNewBlock = false
    @State private var selectedBlock: SavedBlock?
    @State private var showBlockDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Stats Cards
                    statsSection
                    
                    // Filter Tabs
                    filterTabs
                    
                    // Blocks List
                    blocksListSection
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewBlock) {
                NavigationStack {
                    NewBlockView { configuration in
                        viewModel.addBlock(configuration)
                    }
                    .environmentObject(AppSelectionManager.shared)
                }
            }
            .sheet(item: $selectedBlock) { block in
                NavigationStack {
                    BlockDetailView(block: block)
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0A0B2E"),
                Color(hex: "1A1B3E"),
                Color(hex: "0A0B2E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Blocks")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(viewModel.filteredBlocks.count) blocks")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: { showNewBlock = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.purple)
                    .clipShape(Circle())
            }
        }
        .padding()
        .padding(.top, 50)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Active",
                value: "\(viewModel.stats.activeBlocks)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Schedule",
                value: "\(viewModel.stats.scheduleBlocks)",
                icon: "calendar",
                color: .blue
            )
            
            StatCard(
                title: "Timer",
                value: "\(viewModel.stats.timerBlocks)",
                icon: "timer",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: 12) {
            FilterButton(
                title: "All",
                isSelected: viewModel.selectedFilter == .all,
                action: { viewModel.selectedFilter = .all }
            )
            
            FilterButton(
                title: "Active",
                isSelected: viewModel.selectedFilter == .active,
                action: { viewModel.selectedFilter = .active }
            )
            
            FilterButton(
                title: "Schedule",
                isSelected: viewModel.selectedFilter == .schedule,
                action: { viewModel.selectedFilter = .schedule }
            )
            
            FilterButton(
                title: "Timer",
                isSelected: viewModel.selectedFilter == .timer,
                action: { viewModel.selectedFilter = .timer }
            )
        }
        .padding()
    }
    
    // MARK: - Blocks List
    private var blocksListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.filteredBlocks.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.filteredBlocks) { block in
                        BlockRowCard(
                            block: block,
                            onToggle: { viewModel.toggleBlock(block) },
                            onTap: {
                                selectedBlock = block
                                showBlockDetail = true
                            }
                        )
                        .contextMenu {
                            Button(action: {
                                selectedBlock = block
                                showBlockDetail = true
                            }) {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(action: { viewModel.toggleBlock(block) }) {
                                Label(
                                    block.isActive ? "Deactivate" : "Activate",
                                    systemImage: block.isActive ? "pause.circle" : "play.circle"
                                )
                            }
                            
                            Button(role: .destructive, action: { viewModel.deleteBlock(block) }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteBlock(block)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.toggleBlock(block)
                            } label: {
                                Label(
                                    block.isActive ? "Stop" : "Start",
                                    systemImage: block.isActive ? "pause" : "play"
                                )
                            }
                            .tint(block.isActive ? .orange : .green)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Blocks Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Create your first block to start managing your digital wellbeing")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showNewBlock = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Block")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.purple)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple : Color.white.opacity(0.05))
                )
        }
    }
}

// MARK: - Block Row Card
struct BlockRowCard: View {
    let block: SavedBlock
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(block.isActive ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: block.typeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(block.isActive ? .green : .white.opacity(0.6))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(block.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if block.isActive {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(block.configuration.timeRange)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    
                    if block.configuration.type == .schedule {
                        Text(block.configuration.daysString)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Toggle Button
                Button(action: onToggle) {
                    Image(systemName: block.isActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(block.isActive ? .orange : .green)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(block.isActive ? 0.08 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                block.isActive ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    BlocksListView()
}

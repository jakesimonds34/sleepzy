//
//  BlockDetailView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI
import FamilyControls

// MARK: - Block Detail View
struct BlockDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BlockDetailViewModel
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    init(block: SavedBlock) {
        _viewModel = StateObject(wrappedValue: BlockDetailViewModel(block: block))
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // Status Card
                    statusCard
                    
                    // Schedule/Timer Info
                    scheduleInfoCard
                    
                    // Apps List
                    appsListCard
                    
                    // Brake Settings
                    brakeSettingsCard
                    
                    // Metadata
                    metadataCard
                    
                    // Actions
                    actionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Block Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: { viewModel.toggleBlock() }) {
                        Label(
                            viewModel.block.isActive ? "Deactivate" : "Activate",
                            systemImage: viewModel.block.isActive ? "pause" : "play"
                        )
                    }
                    
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Delete Block", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteBlock()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(viewModel.block.displayName)'? This action cannot be undone.")
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
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: viewModel.block.typeIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            // Name
            Text(viewModel.block.displayName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Type Badge
            Text(viewModel.block.configuration.type == .schedule ? "Schedule Block" : "Timer Block")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purple)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.2))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        HStack(spacing: 16) {
            // Status Indicator
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(viewModel.block.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .fill(viewModel.block.isActive ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                }
                
                Text(viewModel.block.isActive ? "Active" : "Inactive")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
                .frame(height: 60)
            
            // Time Info
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.block.configuration.type == .timer {
                    if viewModel.block.isActive, let remaining = viewModel.remainingTime {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time Remaining")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(remaining)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("\(viewModel.block.configuration.durationMinutes) min")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Schedule")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(viewModel.block.configuration.timeRange)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            viewModel.block.isActive ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Schedule Info Card
    private var scheduleInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SCHEDULE DETAILS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            if viewModel.block.configuration.type == .schedule {
                // Days
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repeat On")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 8) {
                        ForEach(WeekDay.allCases, id: \.self) { day in
                            Text(day.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(
                                    viewModel.block.configuration.selectedDays.contains(day) ?
                                    .white : .white.opacity(0.3)
                                )
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(
                                            viewModel.block.configuration.selectedDays.contains(day) ?
                                            Color.purple : Color.white.opacity(0.05)
                                        )
                                )
                        }
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Time Range
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start Time")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(viewModel.block.configuration.fromHour):\(String(format: "%02d", viewModel.block.configuration.fromMinute)) \(viewModel.block.configuration.fromPeriod.rawValue)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white.opacity(0.4))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("End Time")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(viewModel.block.configuration.toHour):\(String(format: "%02d", viewModel.block.configuration.toMinute)) \(viewModel.block.configuration.toPeriod.rawValue)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Timer Duration
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(viewModel.block.configuration.durationMinutes) minutes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
            }
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
    
    // MARK: - Apps List Card
    private var appsListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("BLOCKED APPS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                
                Spacer()
                
                Text("\(viewModel.blockedAppsCount) apps")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            if viewModel.blockedAppsCount > 0 {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.block.configuration.selectedApps.applicationTokens.prefix(5)), id: \.self) { token in
                        HStack(spacing: 12) {
                            Label(token)
                                .labelStyle(.iconOnly)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                )
                            
                            Label(token)
                                .labelStyle(.titleOnly)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    
                    if viewModel.blockedAppsCount > 5 {
                        HStack {
                            Text("+ \(viewModel.blockedAppsCount - 5) more apps")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                        }
                    }
                }
            } else {
                Text("No apps selected")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
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
    
    // MARK: - Brake Settings Card
    private var brakeSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BRAKE SETTINGS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            HStack(spacing: 16) {
                Image(systemName: viewModel.block.configuration.brakeType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.block.configuration.brakeType.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.block.configuration.brakeType.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
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
    
    // MARK: - Metadata Card
    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INFORMATION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            VStack(spacing: 8) {
                MetadataRow(
                    icon: "calendar.badge.plus",
                    title: "Created",
                    value: viewModel.formattedCreatedDate
                )
                
                if let updatedDate = viewModel.formattedUpdatedDate {
                    MetadataRow(
                        icon: "pencil.circle",
                        title: "Last Updated",
                        value: updatedDate
                    )
                }
                
                if let activatedDate = viewModel.formattedLastActivated {
                    MetadataRow(
                        icon: "play.circle",
                        title: "Last Activated",
                        value: activatedDate
                    )
                }
            }
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
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Toggle Button
            Button(action: { viewModel.toggleBlock() }) {
                HStack {
                    Image(systemName: viewModel.block.isActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                    
                    Text(viewModel.block.isActive ? "Deactivate Block" : "Activate Block")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.block.isActive ? Color.orange : Color.green
                )
                .cornerRadius(12)
            }
            
            // Delete Button
            Button(action: { showDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                    
                    Text("Delete Block")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - Metadata Row
struct MetadataRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BlockDetailView(
            block: SavedBlock(
                id: UUID(),
                configuration: BlockConfiguration(
                    name: "Night Time",
                    type: .schedule,
                    fromHour: 10,
                    fromMinute: 0,
                    fromPeriod: .pm,
                    toHour: 7,
                    toMinute: 0,
                    toPeriod: .am,
                    selectedDays: Set(WeekDay.allCases),
                    durationMinutes: 0,
                    selectedApps: FamilyActivitySelection(),
                    brakeType: .takeItEasy
                ),
                isActive: true,
                createdAt: Date()
            )
        )
    }
}

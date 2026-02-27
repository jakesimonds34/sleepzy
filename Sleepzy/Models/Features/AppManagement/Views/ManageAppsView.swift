//
//  ManageAppsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//
/*
import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - Manage Apps View
struct ManageAppsView: View {
    @StateObject private var viewModel = ManageAppsViewModel()
    @State private var showAppPicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Summary Card
                    summaryCard
                    
                    // Apps List
                    appsListSection
                }
            }
            .navigationBarHidden(true)
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $viewModel.tempSelection
            )
            .onChange(of: viewModel.tempSelection) { oldValue, newValue in
                // Handle selection change if needed
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
                Text("Blocked Apps")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(viewModel.allBlockedApps.count) apps currently blocked")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: { showAppPicker = true }) {
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
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Active Blocks
                VStack(spacing: 8) {
                    Text("\(viewModel.activeBlocksCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Active Blocks")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .frame(height: 40)
                
                // Total Blocks
                VStack(spacing: 8) {
                    Text("\(viewModel.totalBlocksCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Total Blocks")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            
            // Quick Actions
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add to Block",
                    icon: "plus.app.fill",
                    color: .purple,
                    action: { showAppPicker = true }
                )
                
                QuickActionButton(
                    title: "View Blocks",
                    icon: "square.stack.3d.up.fill",
                    color: .blue,
                    action: { viewModel.navigateToBlocks() }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Apps List Section
    private var appsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ALL BLOCKED APPS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.allBlockedApps.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(Array(viewModel.allBlockedApps), id: \.self) { token in
                            AppBlockCard(
                                token: token,
                                blocksCount: viewModel.getBlocksCount(for: token),
                                onTap: {
                                    viewModel.showBlocksFor(token)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Blocked Apps")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Create a block to start managing your apps")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: { showAppPicker = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Apps")
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
        .frame(maxHeight: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(10)
        }
    }
}

// MARK: - App Block Card
struct AppBlockCard: View {
    let token: ApplicationToken
    let blocksCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // App Icon
                Label(token)
                    .labelStyle(.iconOnly)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                
                // App Info
                VStack(alignment: .leading, spacing: 6) {
                    Label(token)
                        .labelStyle(.titleOnly)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                        
                        Text("In \(blocksCount) block\(blocksCount == 1 ? "" : "s")")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    ManageAppsView()
}
*/

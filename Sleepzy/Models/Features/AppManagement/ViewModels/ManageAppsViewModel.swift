//
//  ManageAppsViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI
import FamilyControls
import Combine
import ManagedSettings

// MARK: - Manage Apps View Model
class ManageAppsViewModel: ObservableObject {
    @Published var allBlockedApps: Set<ApplicationToken> = []
    @Published var activeBlocksCount: Int = 0
    @Published var totalBlocksCount: Int = 0
    @Published var tempSelection = FamilyActivitySelection()
    
    private let blockManager = BlockManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadData()
    }
    
    func loadData() {
        allBlockedApps = blockManager.getAllBlockedApps()
        
        let stats = blockManager.getStatistics()
        activeBlocksCount = stats.activeBlocks
        totalBlocksCount = stats.totalBlocks
    }
    
    func getBlocksCount(for token: ApplicationToken) -> Int {
        blockManager.getBlocksContaining(appToken: token).count
    }
    
    func showBlocksFor(_ token: ApplicationToken) {
        // This would navigate to a detailed view showing which blocks contain this app
        // For now, we'll just print
        let blocks = blockManager.getBlocksContaining(appToken: token)
        print("App is in \(blocks.count) blocks:")
        blocks.forEach { print("- \($0.displayName)") }
    }
    
    func navigateToBlocks() {
        // This would trigger navigation to BlocksListView
        // In a real app, you'd use NavigationPath or similar
        print("Navigate to blocks list")
    }
    
    private func setupBindings() {
        blockManager.$blocks
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
        
        blockManager.$activeBlocks
            .sink { [weak self] activeBlocks in
                self?.activeBlocksCount = activeBlocks.count
            }
            .store(in: &cancellables)
    }
}

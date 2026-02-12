//
//  BlocksListViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI
import Combine

// MARK: - Block Filter
enum BlockFilter {
    case all
    case active
    case schedule
    case timer
}

// MARK: - Blocks List View Model
class BlocksListViewModel: ObservableObject {
    @Published var blocks: [SavedBlock] = []
    @Published var selectedFilter: BlockFilter = .all
    @Published var stats: BlockStatistics
    
    private let blockManager = BlockManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.stats = blockManager.getStatistics()
        
        // Subscribe to block manager updates
        blockManager.$blocks
            .sink { [weak self] updatedBlocks in
                self?.blocks = updatedBlocks
                self?.stats = self?.blockManager.getStatistics() ?? BlockStatistics(
                    totalBlocks: 0,
                    activeBlocks: 0,
                    scheduleBlocks: 0,
                    timerBlocks: 0
                )
            }
            .store(in: &cancellables)
        
        // Listen for block notifications
        setupNotifications()
    }
    
    var filteredBlocks: [SavedBlock] {
        switch selectedFilter {
        case .all:
            return blocks
        case .active:
            return blocks.filter { $0.isActive }
        case .schedule:
            return blocks.filter { $0.configuration.type == .schedule }
        case .timer:
            return blocks.filter { $0.configuration.type == .timer }
        }
    }
    
    func addBlock(_ configuration: BlockConfiguration) {
        blockManager.addBlock(configuration)
    }
    
    func deleteBlock(_ block: SavedBlock) {
        blockManager.deleteBlock(block)
    }
    
    func toggleBlock(_ block: SavedBlock) {
        if block.isActive {
            blockManager.deactivateBlock(block)
        } else {
            blockManager.activateBlock(block)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .blockCreated)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .blockUpdated)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .blockDeleted)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

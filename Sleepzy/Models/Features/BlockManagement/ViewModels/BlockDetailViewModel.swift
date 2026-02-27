//
//  BlockDetailViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//
/*

import SwiftUI
import Combine
import FamilyControls

// MARK: - Block Detail View Model
class BlockDetailViewModel: ObservableObject {
    @Published var block: SavedBlock
    @Published var remainingTime: String?
    
    private let blockManager = BlockManager.shared
    private let shieldManager = ShieldManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    init(block: SavedBlock) {
        self.block = block
        setupTimer()
        subscribeToUpdates()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    var blockedAppsCount: Int {
        block.configuration.selectedApps.applicationTokens.count +
        block.configuration.selectedApps.categoryTokens.count
    }
    
    var formattedCreatedDate: String {
        formatDate(block.createdAt)
    }
    
    var formattedUpdatedDate: String? {
        guard let date = block.updatedAt else { return nil }
        return formatDate(date)
    }
    
    var formattedLastActivated: String? {
        guard let date = block.lastActivated else { return nil }
        return formatDate(date)
    }
    
    func toggleBlock() {
        if block.isActive {
            blockManager.deactivateBlock(block)
        } else {
            blockManager.activateBlock(block)
        }
    }
    
    func deleteBlock() {
        blockManager.deleteBlock(block)
    }
    
    private func setupTimer() {
        guard block.configuration.type == .timer, block.isActive else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
        updateRemainingTime()
    }
    
    private func updateRemainingTime() {
        guard let timeInterval = shieldManager.getRemainingTime(for: block.id) else {
            remainingTime = nil
            timer?.invalidate()
            return
        }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        remainingTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func subscribeToUpdates() {
        blockManager.$blocks
            .compactMap { blocks in
                blocks.first(where: { $0.id == self.block.id })
            }
            .sink { [weak self] updatedBlock in
                self?.block = updatedBlock
                
                // Restart timer if needed
                if updatedBlock.isActive && updatedBlock.configuration.type == .timer {
                    self?.setupTimer()
                } else {
                    self?.timer?.invalidate()
                    self?.remainingTime = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
*/

//
//  AppSelectionManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI
import FamilyControls
import Combine

// MARK: - App Selection Manager
/// Manages Family Controls app and category selection
class AppSelectionManager: ObservableObject {
    static let shared = AppSelectionManager()
    
    @Published var selection = FamilyActivitySelection()
    
    init() {}
    
    /// Reset selection
    func clearSelection() {
        selection = FamilyActivitySelection()
    }
    
    /// Check if any apps are selected
    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
    
    /// Get count of selected items
    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }
}

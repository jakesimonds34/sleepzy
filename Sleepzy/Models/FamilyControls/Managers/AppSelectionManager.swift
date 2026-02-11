//
//  AppSelectionManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

import Foundation
import FamilyControls
import Combine

final class AppSelectionManager: ObservableObject {
    @Published var selection = FamilyActivitySelection()
}

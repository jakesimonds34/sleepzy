//
//  ScreenTimeAuthorizationManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

import Foundation
import FamilyControls
import DeviceActivity
import Combine

final class ScreenTimeAuthorizationManager: ObservableObject {
    @Published var isAuthorized: Bool = false

    init() {
        Task {
            await refreshAuthorizationStatus()
        }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await refreshAuthorizationStatus()
        } catch {
            print("Authorization failed: \(error)")
        }
    }

    @MainActor
    private func refreshAuthorizationStatus() async {
        let status = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = (status == .approved)
    }
}

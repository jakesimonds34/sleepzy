//
//  DeviceActivityName.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

import DeviceActivity
import FamilyControls
import ManagedSettings

extension DeviceActivityName {
    static let kidsBlockSession = Self("kidsBlockSession")
}

extension ApplicationToken {
    func appName() async -> String {
        (try? await self.displayName()) ?? "Unknown App"
    }
}

//
//  ScheduleManager.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

/*
import Foundation
import DeviceActivity

final class ScheduleManager {
    static let shared = ScheduleManager()
    private let center = DeviceActivityCenter()

    func startBlocking(for minutes: Int) {
        let now = Date()
        guard let end = Calendar.current.date(byAdding: .minute, value: minutes, to: now) else { return }

        let startComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let endComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: end)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )

        do {
            try center.startMonitoring(.kidsBlockSession, during: schedule)
        } catch {
            print("Schedule Error:", error)
        }
    }

    func stopBlocking() {
        center.stopMonitoring([.kidsBlockSession])
    }
}
*/

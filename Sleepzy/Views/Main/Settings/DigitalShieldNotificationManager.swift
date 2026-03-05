import Foundation
import UserNotifications
import os.log

// MARK: - DigitalShieldNotificationManager
// إشعاران:
// 1. قبل تفعيل Digital Shield بـ 30 دقيقة
// 2. عند تفعيل Digital Shield مباشرة

@MainActor
final class DigitalShieldNotificationManager {

    static let shared = DigitalShieldNotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.sleepzy.app", category: "DigitalShield")

    private let minutesBefore: Int = 30

    private let idBefore    = "digitalshield.reminder.before"
    private let idImmediate = "digitalshield.reminder.immediate"
    private let idActive    = "digitalshield.reminder.active"

    private init() {}

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            logger.error("❌ Permission error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Schedule كلا الإشعارين

    func scheduleAll(startTime: DateComponents) async {
        let startH = startTime.hour ?? 22
        let startM = startTime.minute ?? 0

        // ── إشعار 1: قبل التفعيل بـ minutesBefore دقيقة ────────
        let totalMinutes = startH * 60 + startM - minutesBefore
        var fireTime = DateComponents()
        fireTime.hour   = ((totalMinutes / 60) % 24 + 24) % 24
        fireTime.minute = ((totalMinutes % 60) + 60) % 60

        let beforeContent = UNMutableNotificationContent()
        beforeContent.title = "Digital Shield Starting Soon 🛡"
        beforeContent.body  = "Your apps will be blocked in \(minutesBefore) minutes. Wrap up what you're doing."
        beforeContent.sound = .default

        let beforeTrigger = UNCalendarNotificationTrigger(dateMatching: fireTime, repeats: true)
        let beforeRequest = UNNotificationRequest(identifier: idBefore, content: beforeContent, trigger: beforeTrigger)

        // ── إشعار 2: عند التفعيل مباشرة ──────────────────────────
        var activateTime = DateComponents()
        activateTime.hour   = startH
        activateTime.minute = startM

        let activeContent = UNMutableNotificationContent()
        activeContent.title = "Digital Shield Active 🛡"
        activeContent.body  = "Distracting apps are now blocked. Time to rest."
        activeContent.sound = .default

        let activeTrigger = UNCalendarNotificationTrigger(dateMatching: activateTime, repeats: true)
        let activeRequest = UNNotificationRequest(identifier: idActive, content: activeContent, trigger: activeTrigger)

        // احذف القديم أولاً
        center.removePendingNotificationRequests(withIdentifiers: [idBefore, idActive, idImmediate])

        do {
            try await center.add(beforeRequest)
            try await center.add(activeRequest)
            logger.info("✅ Shield notifications scheduled: before=\(fireTime.hour ?? 0):\(String(format: "%02d", fireTime.minute ?? 0)) active=\(startH):\(String(format: "%02d", startM))")
        } catch {
            logger.error("❌ Schedule failed: \(error.localizedDescription)")
        }

        // ── إشعار فوري إذا كنا داخل نافذة الـ minutesBefore ────
        let cal = Calendar.current
        let now = cal.dateComponents([.hour, .minute], from: Date())
        let nowM   = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let fireM  = (fireTime.hour ?? 0) * 60 + (fireTime.minute ?? 0)
        let startTotalM = startH * 60 + startM

        let inWindow: Bool = {
            if fireM <= startTotalM {
                return nowM >= fireM && nowM < startTotalM
            } else {
                return nowM >= fireM || nowM < startTotalM
            }
        }()

        if inWindow {
            let immediateTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let immediateRequest = UNNotificationRequest(identifier: idImmediate, content: beforeContent, trigger: immediateTrigger)
            do {
                try await center.add(immediateRequest)
                logger.info("🚨 Shield immediate notification sent (in window)")
            } catch {
                logger.error("❌ Immediate failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel

    func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [idBefore, idActive, idImmediate])
        logger.info("🗑️ Shield notifications cancelled")
    }
}

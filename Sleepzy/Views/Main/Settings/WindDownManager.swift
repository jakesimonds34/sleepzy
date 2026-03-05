import Foundation
import UserNotifications
import os.log

// MARK: - WindDownManager
// يرسل إشعاراً قبل وقت النوم بـ minutesBefore دقيقة
// المدة ثابتة في الكود — لا يوجد إعداد للمستخدم

@MainActor
final class WindDownManager {

    static let shared = WindDownManager()
    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.sleepzy.app", category: "WindDown")

    // ثابت — 20 دقيقة قبل النوم
    private let minutesBefore: Int = 30  // مؤقت للاختبار — غيّره إلى 30 بعد التأكد  // 30 دقيقة قبل النوم
    private let notificationID         = "winddown.reminder"
    private let notificationIDImmediate = "winddown.reminder.immediate"

    private init() {}

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            logger.info("🔔 Notification permission: \(granted)")
            return granted
        } catch {
            logger.error("❌ Permission error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Schedule from UserProfile bedHour (Double)
    // يقرأ وقت النوم من UserProfileStore مباشرة

    // مفتاح UserDefaults مستقل — لا يعتمد على UserProfile
    private let bedHourKey = "winddown.bedHour"

    // احفظ bedHour — nonisolated حتى يمكن استدعاؤها من أي context
    nonisolated func saveBedHour(_ bedHour: Double) {
        UserDefaults.standard.set(bedHour, forKey: bedHourKey)
    }

    // يستقبل bedHour مباشرة (Double: 7.0 = 7:00 AM, 22.5 = 10:30 PM)
    func scheduleFromBedHour(_ bedHour: Double) async {
        saveBedHour(bedHour)
        let h = Int(bedHour) % 24
        let m = Int((bedHour - Double(Int(bedHour))) * 60)
        logger.info("📥 scheduleFromBedHour: bedHour=\(bedHour) → \(h)h \(m)m")
        await schedule(bedtime: DateComponents(hour: h, minute: m))
    }

    // يقرأ من UserDefaults المستقل
    func scheduleFromProfile() async {
        let bedHour = UserDefaults.standard.double(forKey: bedHourKey)
        let resolved = bedHour == 0 ? 22.0 : bedHour  // default 10 PM
        print("📦 scheduleFromProfile: UserDefaults bedHour=\(bedHour) resolved=\(resolved)")
        logger.info("📥 scheduleFromProfile: bedHour=\(resolved)")
        await scheduleFromBedHour(resolved)
    }

    // MARK: - Schedule

    func schedule(bedtime: DateComponents) async {
        let bedH = bedtime.hour ?? 22
        let bedM = bedtime.minute ?? 0
        print("🛏 schedule() called: bedH=\(bedH) bedM=\(bedM)")

        // وقت الإشعار = وقت النوم - minutesBefore دقيقة
        let totalMinutes = bedH * 60 + bedM - minutesBefore
        var fireTime = DateComponents()
        fireTime.hour   = ((totalMinutes / 60) % 24 + 24) % 24
        fireTime.minute = ((totalMinutes % 60) + 60) % 60

        let content = UNMutableNotificationContent()
        content.title = "Wind Down Time 🌙"
        content.body  = "Your bedtime is in \(minutesBefore) minutes. Start winding down for a better sleep."
        content.sound = .default

        // ── 1. إشعار يومي متكرر (للأيام القادمة) ────────────────
        let dailyTrigger = UNCalendarNotificationTrigger(
            dateMatching: fireTime,
            repeats: true
        )
        let dailyRequest = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: dailyTrigger
        )

        do {
            // احذف القديم أولاً لتجنب التكرار
            center.removePendingNotificationRequests(withIdentifiers: [notificationID, notificationIDImmediate])

            try await center.add(dailyRequest)
            logger.info("✅ Wind Down daily scheduled at \(fireTime.hour ?? 0):\(String(format: "%02d", fireTime.minute ?? 0))")
        } catch {
            logger.error("❌ Daily schedule failed: \(error.localizedDescription)")
        }

        // ── 2. إشعار فوري — إذا كنا داخل نافذة الـ minutesBefore ──
        // مثال: bedtime = 7:00 AM, minutesBefore = 20
        // fireTime = 6:40 AM — إذا الوقت الحالي بين 6:40 و 7:00 أرسل فوراً
        let cal = Calendar.current
        let now = Date()
        let nowComponents = cal.dateComponents([.hour, .minute], from: now)
        let nowMinutes  = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
        let fireMinutes = (fireTime.hour ?? 0) * 60 + (fireTime.minute ?? 0)
        let bedMinutes  = bedH * 60 + bedM

        // هل نحن الآن بين وقت الإشعار ووقت النوم؟
        // نضيف tolerance دقيقة واحدة قبل fireTime للتأكد من عدم الفوات
        let windowStart = fireMinutes - 1
        let inWindow: Bool = {
            if windowStart <= bedMinutes {
                return nowMinutes >= windowStart && nowMinutes <= bedMinutes
            } else {
                return nowMinutes >= windowStart || nowMinutes <= bedMinutes
            }
        }()

        logger.info("⏱ now=\(nowMinutes)m fire=\(fireMinutes)m bed=\(bedMinutes)m inWindow=\(inWindow)")

        if inWindow {
            // أرسل إشعاراً فورياً بعد ثانية واحدة
            let immediateTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1,
                repeats: false
            )
            let immediateRequest = UNNotificationRequest(
                identifier: notificationIDImmediate,
                content: content,
                trigger: immediateTrigger
            )
            do {
                try await center.add(immediateRequest)
                logger.info("🚨 Wind Down immediate notification sent (in window)")
            } catch {
                logger.error("❌ Immediate notification failed: \(error.localizedDescription)")
            }
        } else {
            logger.info("⏭ Not in window — daily trigger only, will fire tomorrow at \(fireTime.hour ?? 0):\(String(format: "%02d", fireTime.minute ?? 0))")
        }
    }

    // MARK: - Debug: print all pending notifications
    func debugPendingNotifications() async {
        let pending = await center.pendingNotificationRequests()
        logger.info("📋 Pending notifications (\(pending.count)):")
        for r in pending {
            logger.info("  - id: \(r.identifier), trigger: \(String(describing: r.trigger))")
        }

        let settings = await center.notificationSettings()
        logger.info("🔔 Auth status: \(settings.authorizationStatus.rawValue) (2=authorized)")
    }

    // MARK: - Cancel

    func cancel() {
        center.removePendingNotificationRequests(
            withIdentifiers: [notificationID, notificationIDImmediate]
        )
        logger.info("🗑️ Wind Down notifications cancelled")
    }
}

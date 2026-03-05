import Foundation
import UserNotifications
import AVFoundation
import AudioToolbox
import Combine

// MARK: - Alarm Model
struct Alarm: Identifiable, Codable {
    var id: UUID = UUID()
    var hour: Int
    var minute: Int
    var isAM: Bool
    var repeatDays: Set<Int>
    var ringtone: String
    var ringtoneURL: String
    var localSoundFile: String?
    var snoozeEnabled: Bool
    var snoozeDuration: Int
    var isEnabled: Bool = true

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var repeatLabel: String {
        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let full = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        if repeatDays.isEmpty       { return "Once" }
        if repeatDays == Set(1...5) { return "Monday to Friday" }
        if repeatDays == Set(1...7) { return "Every Day" }
        if repeatDays == Set([6,7]) { return "Weekends" }
        let s = repeatDays.sorted()
        return s.count <= 3 ? s.map { full[$0-1] }.joined(separator: ", ")
                            : s.map { days[$0-1] }.joined(separator: ", ")
    }

    func timeUntilNextAlarm() -> (hours: Int, minutes: Int) {
        let now = Calendar.current.dateComponents([.hour,.minute], from: Date())
        var h24 = hour
        if !isAM && hour != 12 { h24 = hour + 12 }
        if  isAM && hour == 12 { h24 = 0 }
        var diff = h24*60 + minute - (now.hour ?? 0)*60 - (now.minute ?? 0)
        if diff <= 0 { diff += 1440 }
        return (diff/60, diff%60)
    }
}

// MARK: - AlarmManager
class AlarmManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = AlarmManager()

    @Published var alarms: [Alarm] = []
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var ringingAlarm: Alarm? = nil

    var audioPlayer: AVAudioPlayer?
    var streamPlayer: AVPlayer?
    var streamLoopObserver: Any?

    private var ringingStartTime: Date?
    private let maxRingDelay: TimeInterval = 90
    private let userDefaultsKey = "SavedAlarms"

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadAlarms()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error { print("Permission error: \(error)") }
            DispatchQueue.main.async { self.checkAuthorizationStatus() }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async { self.authorizationStatus = s.authorizationStatus }
        }
    }

    // MARK: - Notification Categories
    // يُستدعى مرة واحدة من AppDelegate — بدون async معقد
    func setupNotificationCategories() {
        let snooze = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: [.foreground]
        )
        let dismiss = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        let withSnooze = UNNotificationCategory(
            identifier: "ALARM_WITH_SNOOZE",
            actions: [snooze, dismiss],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let noSnooze = UNNotificationCategory(
            identifier: "ALARM_NO_SNOOZE",
            actions: [dismiss],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([withSnooze, noSnooze])
        print("✅ Categories registered")
    }

    // MARK: - CRUD
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        guard alarm.isEnabled else { return }

        // إذا كان الصوت محمّلاً مسبقاً (من onSelected في AlarmFormView) → جدول مباشرة
        if alarm.localSoundFile != nil || alarm.ringtoneURL.isEmpty {
            scheduleNotification(for: alarm)
            return
        }

        // لم يُحمَّل بعد → حمّل ثم جدول
        AlarmSoundManager.shared.downloadAndPrepare(
            url: alarm.ringtoneURL,
            alarmId: alarm.id.uuidString
        ) { [weak self] fileName in
            guard let self else { return }
            if let i = self.alarms.firstIndex(where: { $0.id == alarm.id }) {
                self.alarms[i].localSoundFile = fileName
                self.saveAlarms()
                self.scheduleNotification(for: self.alarms[i])
            }
        }
    }

    func updateAlarm(_ alarm: Alarm) {
        guard let i = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        cancelNotification(for: alarms[i])
        alarms[i] = alarm
        saveAlarms()
        guard alarm.isEnabled else { return }

        // إذا تغيّر الـ URL → حمّل الصوت الجديد
        let urlChanged = alarm.ringtoneURL != (alarm.localSoundFile.map { _ in alarm.ringtoneURL } ?? "")
        if !alarm.ringtoneURL.isEmpty && alarm.localSoundFile == nil {
            AlarmSoundManager.shared.downloadAndPrepare(
                url: alarm.ringtoneURL,
                alarmId: alarm.id.uuidString
            ) { [weak self] fileName in
                guard let self else { return }
                if let j = self.alarms.firstIndex(where: { $0.id == alarm.id }) {
                    self.alarms[j].localSoundFile = fileName
                    self.saveAlarms()
                    self.scheduleNotification(for: self.alarms[j])
                }
            }
        } else {
            scheduleNotification(for: alarm)
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        cancelNotification(for: alarm)
        AlarmSoundManager.shared.deleteSound(fileName: alarm.localSoundFile)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        var a = alarm; a.isEnabled.toggle(); updateAlarm(a)
    }

    // MARK: - Schedule Notification
    // مباشر — بدون async إضافي
    func scheduleNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()

        var h24 = alarm.hour
        if !alarm.isAM && alarm.hour != 12 { h24 = alarm.hour + 12 }
        if  alarm.isAM && alarm.hour == 12 { h24 = 0 }

        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm"
        content.body  = "Time to wake up!"
        content.categoryIdentifier = alarm.snoozeEnabled ? "ALARM_WITH_SNOOZE" : "ALARM_NO_SNOOZE"
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }
        content.userInfo = [
            "alarmId":        alarm.id.uuidString,
            "ringtoneURL":    alarm.ringtoneURL,
            "ringtone":       alarm.ringtone,
            "snoozeDuration": alarm.snoozeDuration,
            "snoozeEnabled":  alarm.snoozeEnabled
        ]
        content.sound = buildNotificationSound(for: alarm)
        print("🔔 Sound set: \(alarm.localSoundFile ?? "default")")

        if alarm.repeatDays.isEmpty {
            var dc = DateComponents()
            dc.hour   = h24
            dc.minute = alarm.minute
            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
            )
            center.add(request) { err in
                if let err {
                    print("❌ Schedule error: \(err)")
                } else {
                    print("✅ Alarm scheduled: \(h24):\(alarm.minute)")
                }
            }
        } else {
            for day in alarm.repeatDays {
                var dc = DateComponents()
                dc.weekday = dayToWeekday(day)
                dc.hour    = h24
                dc.minute  = alarm.minute
                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)_\(day)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                )
                center.add(request) { err in
                    if let err { print("❌ Schedule error day\(day): \(err)") }
                }
            }
            print("✅ Alarm scheduled for days: \(alarm.repeatDays) at \(h24):\(alarm.minute)")
        }
    }

    func cancelNotification(for alarm: Alarm) {
        var ids = [alarm.id.uuidString, "\(alarm.id.uuidString)_snooze"]
        for d in 1...7 { ids.append("\(alarm.id.uuidString)_\(d)") }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func dayToWeekday(_ d: Int) -> Int { [2,3,4,5,6,7,1][d-1] }

    // ✅ الحل الصحيح: نسخ الملف إلى Library/Sounds
    // iOS يقرأ الأصوات من هذا المجلد داخل الـ sandbox
    private func buildNotificationSound(for alarm: Alarm) -> UNNotificationSound {
        guard let fileName = alarm.localSoundFile,
              let srcURL   = AlarmSoundManager.shared.localMP3URL(fileName: fileName)
        else {
            return .defaultCriticalSound(withAudioVolume: 1.0)
        }

        // مجلد Library/Sounds
        let libSounds = FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Sounds", isDirectory: true)

        do {
            try FileManager.default.createDirectory(
                at: libSounds, withIntermediateDirectories: true)

            let destURL  = libSounds.appendingPathComponent("\(fileName).mp3")

            // انسخ إذا لم يكن موجوداً أو إذا تغيّر الحجم
            let srcSize  = (try? FileManager.default.attributesOfItem(atPath: srcURL.path)[.size] as? Int) ?? 0
            let destSize = (try? FileManager.default.attributesOfItem(atPath: destURL.path)[.size] as? Int) ?? 0

            if !FileManager.default.fileExists(atPath: destURL.path) || srcSize != destSize {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                print("✅ Copied to Library/Sounds: \(fileName).mp3")
            }

            return UNNotificationSound(
                named: UNNotificationSoundName(rawValue: "\(fileName).mp3")
            )
        } catch {
            print("❌ Library/Sounds error: \(error)")
            return .defaultCriticalSound(withAudioVolume: 1.0)
        }
    }

    // MARK: - In-App Audio
    func playAlarmSound(ringtone: String, ringtoneURL: String, localSoundFile: String? = nil) {
        stopAlarmSound()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("AudioSession: \(error)") }

        // 1. ملف محلي
        if let fileName = localSoundFile,
           let url = AlarmSoundManager.shared.localMP3URL(fileName: fileName),
           let p = try? AVAudioPlayer(contentsOf: url) {
            p.numberOfLoops = -1; p.volume = 1.0; p.play()
            audioPlayer = p
            print("▶️ Playing local file")
            return
        }
        // 2. Streaming
        if !ringtoneURL.isEmpty, let url = URL(string: ringtoneURL) {
            let item = AVPlayerItem(url: url)
            streamPlayer = AVPlayer(playerItem: item)
            streamPlayer?.volume = 1.0
            streamPlayer?.automaticallyWaitsToMinimizeStalling = true
            streamPlayer?.play()
            streamLoopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item, queue: .main
            ) { [weak self] _ in
                self?.streamPlayer?.seek(to: .zero)
                self?.streamPlayer?.play()
            }
            print("▶️ Streaming from URL")
            return
        }
        // 3. Bundle
        if let url = Bundle.main.url(forResource: ringtone, withExtension: "mp3"),
           let p = try? AVAudioPlayer(contentsOf: url) {
            p.numberOfLoops = -1; p.volume = 1.0; p.play()
            audioPlayer = p
            return
        }
        // 4. Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    func stopAlarmSound() {
        if let obs = streamLoopObserver {
            NotificationCenter.default.removeObserver(obs)
            streamLoopObserver = nil
        }
        streamPlayer?.pause(); streamPlayer = nil
        audioPlayer?.stop();   audioPlayer  = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Dismiss / Snooze
    func dismissRingingAlarm() {
        stopAlarmSound()
        ringingAlarm = nil
        ringingStartTime = nil
    }

    func snoozeRingingAlarm() {
        guard let alarm = ringingAlarm else { return }
        stopAlarmSound()
        ringingAlarm = nil
        ringingStartTime = nil
        scheduleSnooze(for: alarm)
    }

    func scheduleSnooze(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm (Snoozed)"
        content.body  = "Snooze is over. Time to wake up!"
        content.categoryIdentifier = alarm.snoozeEnabled ? "ALARM_WITH_SNOOZE" : "ALARM_NO_SNOOZE"
        if #available(iOS 15.0, *) { content.interruptionLevel = .timeSensitive }
        content.userInfo = [
            "alarmId":        alarm.id.uuidString,
            "ringtoneURL":    alarm.ringtoneURL,
            "ringtone":       alarm.ringtone,
            "snoozeDuration": alarm.snoozeDuration,
            "snoozeEnabled":  alarm.snoozeEnabled
        ]
        content.sound = buildNotificationSound(for: alarm)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Double(alarm.snoozeDuration * 60), repeats: false
        )
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)_snooze",
                content: content,
                trigger: trigger
            )
        )
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let info    = notification.request.content.userInfo
        let alarmId = info["alarmId"] as? String ?? ""
        let baseId  = extractBaseId(alarmId)

        if let alarm = alarms.first(where: { $0.id.uuidString == baseId }) {
            ringingStartTime = Date()
            playAlarmSound(
                ringtone:       alarm.ringtone,
                ringtoneURL:    alarm.ringtoneURL,
                localSoundFile: alarm.localSoundFile
            )
            DispatchQueue.main.async { self.ringingAlarm = alarm }
        }
        completionHandler([.badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let info        = response.notification.request.content.userInfo
        let alarmId     = info["alarmId"]        as? String ?? ""
        let ringtone    = info["ringtone"]        as? String ?? ""
        let ringtoneURL = info["ringtoneURL"]     as? String ?? ""
        let snoozeDur   = info["snoozeDuration"]  as? Int    ?? 5
        let snoozeOn    = info["snoozeEnabled"]   as? Bool   ?? false
        let baseId      = extractBaseId(alarmId)
        let alarm       = alarms.first(where: { $0.id.uuidString == baseId })
        let elapsed     = Date().timeIntervalSince(response.notification.date)

        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            let target = alarm ?? Alarm(
                hour: 0, minute: 0, isAM: true, repeatDays: [],
                ringtone: ringtone, ringtoneURL: ringtoneURL,
                snoozeEnabled: snoozeOn, snoozeDuration: snoozeDur
            )
            scheduleSnooze(for: target)
            stopAlarmSound()
            DispatchQueue.main.async { self.ringingAlarm = nil }

        case "DISMISS_ACTION":
            stopAlarmSound()
            DispatchQueue.main.async { self.ringingAlarm = nil }

        default:
            if elapsed <= maxRingDelay, let alarm {
                ringingStartTime = Date()
                playAlarmSound(
                    ringtone:       alarm.ringtone,
                    ringtoneURL:    alarm.ringtoneURL,
                    localSoundFile: alarm.localSoundFile
                )
                DispatchQueue.main.async { self.ringingAlarm = alarm }
            }
        }
        completionHandler()
    }

    private func extractBaseId(_ id: String) -> String {
        id.replacingOccurrences(of: "_snooze", with: "")
          .components(separatedBy: "_").first ?? id
    }

    // MARK: - Persistence
    func saveAlarms() {
        if let d = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(d, forKey: userDefaultsKey)
        }
    }

    func loadAlarms() {
        if let d = UserDefaults.standard.data(forKey: userDefaultsKey),
           let a = try? JSONDecoder().decode([Alarm].self, from: d) {
            alarms = a
        }
    }
}

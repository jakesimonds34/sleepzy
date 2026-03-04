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
    var snoozeEnabled: Bool
    var snoozeDuration: Int
    var isEnabled: Bool = true

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var repeatLabel: String {
        let days    = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let full    = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        if repeatDays.isEmpty          { return "Once" }
        if repeatDays == Set(1...5)    { return "Monday to Friday" }
        if repeatDays == Set(1...7)    { return "Every Day" }
        if repeatDays == Set([6,7])    { return "Weekends" }
        let s = repeatDays.sorted()
        return s.count <= 3 ? s.map { full[$0-1] }.joined(separator: ", ")
                            : s.map { days[$0-1] }.joined(separator: ", ")
    }

    func timeUntilNextAlarm() -> (hours: Int, minutes: Int) {
        let now  = Calendar.current.dateComponents([.hour,.minute], from: Date())
        var h24  = hour
        if !isAM && hour != 12 { h24 = hour + 12 }
        if  isAM && hour == 12 { h24 = 0 }
        var diff = h24 * 60 + minute - (now.hour ?? 0) * 60 - (now.minute ?? 0)
        if diff <= 0 { diff += 1440 }
        return (diff / 60, diff % 60)
    }
}

// MARK: - AlarmManager
class AlarmManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = AlarmManager()

    @Published var alarms: [Alarm] = []
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // ← شاشة الرنين تراقب هذا
    @Published var ringingAlarm: Alarm? = nil

    // Audio
    var audioPlayer: AVAudioPlayer?
    var streamPlayer: AVPlayer?
    var streamLoopObserver: Any?

    // الوقت الذي بدأ فيه الرنين — لتجاهل الضغط على إشعار قديم
    private var ringingStartTime: Date? = nil
    private let maxRingDelay: TimeInterval = 90  // تجاهل إذا مرّ أكثر من 90 ثانية

    private let userDefaultsKey = "SavedAlarms"

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadAlarms()
        checkAuthorizationStatus()
        // سجّل الأزرار فور الإطلاق
        setupNotificationCategories()
    }

    // MARK: - Authorization
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { _, _ in
            DispatchQueue.main.async { self.checkAuthorizationStatus() }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async { self.authorizationStatus = s.authorizationStatus }
        }
    }

    // MARK: - CRUD
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        if alarm.isEnabled { scheduleNotification(for: alarm) }
        saveAlarms()
    }

    func updateAlarm(_ alarm: Alarm) {
        if let i = alarms.firstIndex(where: { $0.id == alarm.id }) {
            cancelNotification(for: alarms[i])
            alarms[i] = alarm
            if alarm.isEnabled { scheduleNotification(for: alarm) }
            saveAlarms()
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        cancelNotification(for: alarm)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        var a = alarm; a.isEnabled.toggle(); updateAlarm(a)
    }

    // MARK: - Schedule Notification
    func scheduleNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()

        var h24 = alarm.hour
        if !alarm.isAM && alarm.hour != 12 { h24 = alarm.hour + 12 }
        if  alarm.isAM && alarm.hour == 12 { h24 = 0 }

        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm"
        content.body  = alarm.repeatLabel == "Once"
                        ? "Time to wake up!"
                        : "\(alarm.repeatLabel) — Time to wake up!"
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
        content.categoryIdentifier = alarm.snoozeEnabled ? "ALARM_WITH_SNOOZE" : "ALARM_NO_SNOOZE"
        content.userInfo = [
            "alarmId":        alarm.id.uuidString,
            "ringtoneURL":    alarm.ringtoneURL,
            "ringtone":       alarm.ringtone,
            "snoozeDuration": alarm.snoozeDuration,
            "snoozeEnabled":  alarm.snoozeEnabled
        ]

        if alarm.repeatDays.isEmpty {
            var dc = DateComponents(); dc.hour = h24; dc.minute = alarm.minute
            center.add(UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
            ))
        } else {
            for day in alarm.repeatDays {
                var dc = DateComponents()
                dc.weekday = dayToWeekday(day)
                dc.hour    = h24
                dc.minute  = alarm.minute
                center.add(UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)_\(day)",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                ))
            }
        }
    }

    func cancelNotification(for alarm: Alarm) {
        var ids = [alarm.id.uuidString]
        for d in 1...7 { ids.append("\(alarm.id.uuidString)_\(d)") }
        ids.append("\(alarm.id.uuidString)_snooze")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func dayToWeekday(_ day: Int) -> Int {
        [2,3,4,5,6,7,1][day - 1]
    }

    // MARK: - Notification Categories
    // مجموعتان: مع Snooze وبدون Snooze
    func setupNotificationCategories() {
        let dismiss = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive, .foreground]
        )
        let snooze5 = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: [.foreground]
        )

        let withSnooze = UNNotificationCategory(
            identifier: "ALARM_WITH_SNOOZE",
            actions: [snooze5, dismiss],
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
    }

    // MARK: - Audio Playback

    func playAlarmSound(ringtone: String, ringtoneURL: String) {
        stopAlarmSound()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("AudioSession: \(error)") }

        // Freesound HTTP URL
        if !ringtoneURL.isEmpty, let url = URL(string: ringtoneURL) {
            let item  = AVPlayerItem(url: url)
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
            return
        }

        // Bundle file
        if let url = Bundle.main.url(forResource: ringtone, withExtension: "mp3") {
            if let p = try? AVAudioPlayer(contentsOf: url) {
                p.numberOfLoops = -1; p.volume = 1.0; p.play()
                audioPlayer = p
            }
            return
        }

        // Vibrate fallback
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

    // MARK: - Dismiss / Snooze (من شاشة الرنين في التطبيق)

    func dismissRingingAlarm() {
        stopAlarmSound()
        ringingAlarm    = nil
        ringingStartTime = nil
    }

    func snoozeRingingAlarm() {
        guard let alarm = ringingAlarm else { return }
        stopAlarmSound()
        ringingAlarm    = nil
        ringingStartTime = nil
        scheduleSnooze(for: alarm)
    }

    func scheduleSnooze(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm (Snoozed)"
        content.body  = "Snooze is over. Time to wake up!"
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
        content.categoryIdentifier = alarm.snoozeEnabled ? "ALARM_WITH_SNOOZE" : "ALARM_NO_SNOOZE"
        content.userInfo = [
            "alarmId":        alarm.id.uuidString,
            "ringtoneURL":    alarm.ringtoneURL,
            "ringtone":       alarm.ringtone,
            "snoozeDuration": alarm.snoozeDuration,
            "snoozeEnabled":  alarm.snoozeEnabled
        ]
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

    /// التطبيق مفتوح في المقدمة — يُشغّل صوت التطبيق ويعرض شاشة الرنين
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let info       = notification.request.content.userInfo
        let alarmId    = info["alarmId"]    as? String ?? ""
        let ringtoneURL = info["ringtoneURL"] as? String ?? ""
        let ringtone    = info["ringtone"]   as? String ?? ""

        let baseId = extractBaseId(alarmId)

        if let alarm = alarms.first(where: { $0.id.uuidString == baseId }) {
            ringingStartTime = Date()
            playAlarmSound(ringtone: alarm.ringtone, ringtoneURL: alarm.ringtoneURL)
            DispatchQueue.main.async { self.ringingAlarm = alarm }
        } else {
            // المنبه غير موجود في القائمة (مُحذوف) — استخدم بيانات الإشعار
            let dummy = Alarm(
                hour: 0, minute: 0, isAM: true, repeatDays: [],
                ringtone: ringtone, ringtoneURL: ringtoneURL,
                snoozeEnabled: (info["snoozeEnabled"] as? Bool) ?? false,
                snoozeDuration: (info["snoozeDuration"] as? Int) ?? 5
            )
            ringingStartTime = Date()
            playAlarmSound(ringtone: ringtone, ringtoneURL: ringtoneURL)
            DispatchQueue.main.async { self.ringingAlarm = dummy }
        }

        // لا نعرض Banner لأن شاشة الرنين تغطي كل شيء
        completionHandler([.badge])
    }

    /// المستخدم ضغط على زر في الإشعار (التطبيق في الخلفية أو مغلق)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let info        = response.notification.request.content.userInfo
        let alarmId     = info["alarmId"]    as? String ?? ""
        let ringtone    = info["ringtone"]   as? String ?? ""
        let ringtoneURL = info["ringtoneURL"] as? String ?? ""
        let snoozeDur   = info["snoozeDuration"] as? Int ?? 5
        let snoozeOn    = info["snoozeEnabled"]  as? Bool ?? false

        let baseId      = extractBaseId(alarmId)
        let alarm       = alarms.first(where: { $0.id.uuidString == baseId })

        // وقت إرسال الإشعار
        let notifDate   = response.notification.date
        let elapsed     = Date().timeIntervalSince(notifDate)

        switch response.actionIdentifier {

        case "SNOOZE_ACTION":
            // Snooze من إشعار النظام — بغض النظر عن الوقت
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
            // المستخدم فتح التطبيق بالضغط على الإشعار
            // ✅ لا نشغّل الصوت إذا مرّ أكثر من maxRingDelay ثانية
            if elapsed <= maxRingDelay {
                if let alarm {
                    ringingStartTime = Date()
                    playAlarmSound(ringtone: alarm.ringtone, ringtoneURL: alarm.ringtoneURL)
                    DispatchQueue.main.async { self.ringingAlarm = alarm }
                }
            }
            // إذا مرّ وقت طويل → لا صوت، لا شاشة رنين
        }

        completionHandler()
    }

    // MARK: - Helpers

    private func extractBaseId(_ alarmId: String) -> String {
        alarmId
            .replacingOccurrences(of: "_snooze", with: "")
            .components(separatedBy: "_").first ?? alarmId
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

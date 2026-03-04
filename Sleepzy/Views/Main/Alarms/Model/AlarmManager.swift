import Foundation
import UserNotifications
import AVFoundation
import Combine

// MARK: - Alarm Model
struct Alarm: Identifiable, Codable {
    var id: UUID = UUID()
    var hour: Int
    var minute: Int
    var isAM: Bool
    var repeatDays: Set<Int> // 1=Monday, 2=Tuesday, ..., 7=Sunday
    var ringtone: String
    var ringtoneURL: String  // Freesound preview URL (empty = use system sound)
    var snoozeEnabled: Bool
    var snoozeDuration: Int // minutes
    var isEnabled: Bool = true
    
    var timeString: String {
        let h = isAM ? (hour == 0 ? 12 : hour) : (hour == 12 ? 12 : hour)
        return String(format: "%02d:%02d", h, minute)
    }
    
    var repeatLabel: String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let fullDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        
        if repeatDays.isEmpty { return "Once" }
        if repeatDays == Set(1...5) { return "Monday to Friday" }
        if repeatDays == Set(1...7) { return "Every Day" }
        if repeatDays == Set([6, 7]) { return "Weekends" }
        
        let sorted = repeatDays.sorted()
        if sorted.count <= 3 {
            return sorted.map { fullDays[$0 - 1] }.joined(separator: ", ")
        }
        return sorted.map { days[$0 - 1] }.joined(separator: ", ")
    }
    
    // Calculate hours/minutes until next alarm fires
    func timeUntilNextAlarm() -> (hours: Int, minutes: Int) {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute, .weekday], from: now)
        
        let currentHour = components.hour ?? 0
        let currentMinute = components.minute ?? 0
        
        // Convert alarm to 24h
        var alarmHour24 = hour
        if !isAM && hour != 12 { alarmHour24 = hour + 12 }
        if isAM && hour == 12 { alarmHour24 = 0 }
        
        let alarmTotalMinutes = alarmHour24 * 60 + minute
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        var diff = alarmTotalMinutes - currentTotalMinutes
        if diff <= 0 { diff += 24 * 60 }
        
        return (diff / 60, diff % 60)
    }
}

// MARK: - AlarmManager
class AlarmManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = AlarmManager()
    
    @Published var alarms: [Alarm] = []
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var ringingAlarm: Alarm? = nil   // ← الشاشة تراقب هذا لتظهر/تختفي

    var audioPlayer: AVAudioPlayer?
    var streamPlayer: AVPlayer?
    var streamLoopObserver: Any?
    
    private let userDefaultsKey = "SavedAlarms"
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadAlarms()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.checkAuthorizationStatus()
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - CRUD
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        if alarm.isEnabled {
            scheduleNotification(for: alarm)
        }
        saveAlarms()
    }
    
    func updateAlarm(_ alarm: Alarm) {
        if let idx = alarms.firstIndex(where: { $0.id == alarm.id }) {
            cancelNotification(for: alarms[idx])
            alarms[idx] = alarm
            if alarm.isEnabled {
                scheduleNotification(for: alarm)
            }
            saveAlarms()
        }
    }
    
    func deleteAlarm(_ alarm: Alarm) {
        cancelNotification(for: alarm)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        var updated = alarm
        updated.isEnabled.toggle()
        updateAlarm(updated)
    }
    
    // MARK: - Scheduling Notifications
    func scheduleNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()
        
        // Convert to 24h
        var alarmHour24 = alarm.hour
        if !alarm.isAM && alarm.hour != 12 { alarmHour24 = alarm.hour + 12 }
        if alarm.isAM && alarm.hour == 12 { alarmHour24 = 0 }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm"
        content.body = "Good morning! Time to wake up."
        content.sound = buildNotificationSound(ringtone: alarm.ringtone)
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]
        
        if alarm.repeatDays.isEmpty {
            // One-time alarm
            var dateComponents = DateComponents()
            dateComponents.hour = alarmHour24
            dateComponents.minute = alarm.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = alarm.id.uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        } else {
            // Repeating alarm per day
            for day in alarm.repeatDays {
                var dateComponents = DateComponents()
                dateComponents.weekday = dayToWeekday(day) // Sunday=1 in iOS
                dateComponents.hour = alarmHour24
                dateComponents.minute = alarm.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "\(alarm.id.uuidString)_\(day)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request)
            }
        }
        
        // Register snooze action if enabled
        setupNotificationCategories(snoozeMinutes: alarm.snoozeDuration)
    }
    
    func cancelNotification(for alarm: Alarm) {
        var identifiers = [alarm.id.uuidString]
        for day in 1...7 {
            identifiers.append("\(alarm.id.uuidString)_\(day)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    private func buildNotificationSound(ringtone: String) -> UNNotificationSound {
        // Use default critical sound for maximum reliability
        if #available(iOS 15.2, *) {
            return .defaultCritical
        }
        return .defaultCriticalSound(withAudioVolume: 1.0)
    }
    
    private func dayToWeekday(_ day: Int) -> Int {
        // Our model: 1=Monday, 7=Sunday
        // iOS Calendar: 1=Sunday, 2=Monday, ..., 7=Saturday
        let mapping = [2, 3, 4, 5, 6, 7, 1] // Mon->2, Tue->3, ..., Sun->1
        return mapping[day - 1]
    }
    
    // MARK: - Notification Categories (for Snooze button)
    func setupNotificationCategories(snoozeMinutes: Int) {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze \(snoozeMinutes) min",
            options: []
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        let category = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - In-App Audio (when app is open)
    func playAlarmSound(ringtone: String, ringtoneURL: String = "") {
        stopAlarmSound()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("AudioSession error: \(error)") }

        // أولوية: Freesound URL (HTTP) → ملف Bundle → اهتزاز
        if !ringtoneURL.isEmpty, let url = URL(string: ringtoneURL) {
            // AVPlayer يدعم HTTP streaming — نحتفظ بـ reference قوية في streamPlayer
            let item = AVPlayerItem(url: url)
            streamPlayer = AVPlayer(playerItem: item)
            streamPlayer?.volume = 1.0
            streamPlayer?.automaticallyWaitsToMinimizeStalling = true
            streamPlayer?.play()

            // تكرار الصوت عند الانتهاء
            streamLoopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                self?.streamPlayer?.seek(to: .zero)
                self?.streamPlayer?.play()
            }
            return
        }

        // ملف محلي في Bundle
        if let url = Bundle.main.url(forResource: ringtone, withExtension: "mp3") ??
                     Bundle.main.url(forResource: "alarm_default", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch { print("AVAudioPlayer error: \(error)") }
            return
        }

        // fallback: اهتزاز
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    func stopAlarmSound() {
        // إيقاف stream player
        if let obs = streamLoopObserver {
            NotificationCenter.default.removeObserver(obs)
            streamLoopObserver = nil
        }
        streamPlayer?.pause()
        streamPlayer = nil

        // إيقاف local player
        audioPlayer?.stop()
        audioPlayer = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - UNUserNotificationCenterDelegate

    /// يُستدعى عندما يصل الإشعار والتطبيق مفتوح في المقدمة
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let alarmId = notification.request.content.userInfo["alarmId"] as? String ?? ""

        // استخرج الـ alarmId الأصلي (بدون suffix اليوم أو _snooze)
        let baseId = alarmId
            .replacingOccurrences(of: "_snooze", with: "")
            .components(separatedBy: "_").first ?? alarmId

        if let alarm = alarms.first(where: { $0.id.uuidString == baseId }) {
            // شغّل الصوت
            playAlarmSound(ringtone: alarm.ringtone, ringtoneURL: alarm.ringtoneURL)
            // أظهر شاشة الرنين
            DispatchQueue.main.async { self.ringingAlarm = alarm }
        }
        // لا نعرض Banner لأن شاشة الرنين ستظهر
        completionHandler([.badge])
    }

    /// يُستدعى عند الضغط على الإشعار أو أزرار الـ action (التطبيق في الخلفية)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let alarmId = response.notification.request.content.userInfo["alarmId"] as? String ?? ""
        let baseId = alarmId
            .replacingOccurrences(of: "_snooze", with: "")
            .components(separatedBy: "_").first ?? alarmId

        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            if let alarm = alarms.first(where: { $0.id.uuidString == baseId }) {
                scheduleSnooze(for: alarm)
            }
            DispatchQueue.main.async { self.ringingAlarm = nil }
            stopAlarmSound()

        case "DISMISS_ACTION":
            stopAlarmSound()
            DispatchQueue.main.async { self.ringingAlarm = nil }

        default:
            // المستخدم فتح التطبيق بالضغط على الإشعار → أظهر شاشة الرنين
            if let alarm = alarms.first(where: { $0.id.uuidString == baseId }) {
                playAlarmSound(ringtone: alarm.ringtone, ringtoneURL: alarm.ringtoneURL)
                DispatchQueue.main.async { self.ringingAlarm = alarm }
            }
        }
        completionHandler()
    }

    // MARK: - Dismiss & Snooze (من شاشة الرنين)

    func dismissRingingAlarm() {
        stopAlarmSound()
        ringingAlarm = nil
    }

    func snoozeRingingAlarm() {
        guard let alarm = ringingAlarm else { return }
        stopAlarmSound()
        ringingAlarm = nil
        scheduleSnooze(for: alarm)
    }
    
    func scheduleSnooze(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Alarm (Snoozed)"
        content.body = "Snooze is over. Time to wake up!"
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(alarm.snoozeDuration * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "\(alarm.id.uuidString)_snooze", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Persistence
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
        }
    }
}

import AudioToolbox

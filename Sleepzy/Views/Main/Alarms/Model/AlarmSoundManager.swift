import Foundation
import AVFoundation

// MARK: - AlarmSoundManager
//
// ⚠️ قيد iOS الحقيقي:
// UNNotificationSound يدعم فقط ملفات في Main Bundle
// (مُضمَّنة وقت البناء في Xcode)
// لا يمكن تشغيل ملف محمّل runtime من الإنترنت في الإشعار.
//
// الحل المعتمد:
// - الصوت المخصص يعمل عندما التطبيق مفتوح أو في الخلفية (AVPlayer)
// - عندما التطبيق مغلق: يُشغَّل الصوت الافتراضي للإشعار
// - عند فتح التطبيق بالضغط على الإشعار: يبدأ الصوت المخصص ✅
//
// لتشغيل صوت مخصص والتطبيق مغلق تماماً:
// يحتاج Notification Service Extension (مشروع منفصل في Xcode)

class AlarmSoundManager {

    static let shared = AlarmSoundManager()

    private var cacheDirURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AlarmSounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - تحميل وحفظ الـ mp3 محلياً (للتشغيل داخل التطبيق)
    func downloadAndPrepare(
        url: String,
        alarmId: String,
        completion: @escaping (_ localFileName: String?) -> Void
    ) {
        guard !url.isEmpty, let remoteURL = URL(string: url) else {
            completion(nil); return
        }

        let fileName = "alarm_\(alarmId)"
        let mp3Path  = cacheDirURL.appendingPathComponent("\(fileName).mp3")

        // إذا كان موجوداً مسبقاً
        if FileManager.default.fileExists(atPath: mp3Path.path) {
            print("✅ Sound already cached: \(fileName)")
            completion(fileName)
            return
        }

        // حمّل من الإنترنت
        URLSession.shared.downloadTask(with: remoteURL) { tmpURL, response, error in
            if let error {
                print("❌ Download error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let tmpURL else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                try FileManager.default.copyItem(at: tmpURL, to: mp3Path)
                print("✅ Sound downloaded: \(fileName).mp3")
                DispatchQueue.main.async { completion(fileName) }
            } catch {
                print("❌ Save error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    // MARK: - مسار الملف المحلي للتشغيل داخل التطبيق
    func localMP3URL(fileName: String) -> URL? {
        let url = cacheDirURL.appendingPathComponent("\(fileName).mp3")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - حذف ملف الصوت عند حذف المنبه
    func deleteSound(fileName: String?) {
        guard let name = fileName else { return }
        try? FileManager.default.removeItem(at: cacheDirURL.appendingPathComponent("\(name).mp3"))
    }

    // notificationSoundName — لا يُستخدم لأن iOS لا يدعم runtime sounds في الإشعارات
    // نبقيه للتوافق لكنه يرجع nil دائماً
    func notificationSoundName(for alarm: Alarm) -> String? { nil }
}

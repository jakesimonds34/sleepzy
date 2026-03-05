import Foundation

class AlarmSoundManager {

    static let shared = AlarmSoundManager()

    // مجلد حفظ الـ mp3 الأصلي
    private var cacheDir: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AlarmSounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // ✅ Library/Sounds — iOS يقرأ منه أصوات الإشعارات
    private var librarySoundsDir: URL {
        let dir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Sounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - تحميل الصوت وحفظه في المكانين

    func downloadAndPrepare(
        url: String,
        alarmId: String,
        completion: @escaping (_ localFileName: String?) -> Void
    ) {
        guard !url.isEmpty, let remoteURL = URL(string: url) else {
            completion(nil); return
        }

        let fileName  = "alarm_\(alarmId)"
        let mp3URL    = cacheDir.appendingPathComponent("\(fileName).mp3")
        let libURL    = librarySoundsDir.appendingPathComponent("\(fileName).mp3")

        // إذا كان موجوداً في كلا المكانين → لا حاجة للتحميل
        if FileManager.default.fileExists(atPath: mp3URL.path) &&
           FileManager.default.fileExists(atPath: libURL.path) {
            print("✅ Already cached: \(fileName)")
            completion(fileName)
            return
        }
        // احذف أي ملفات قديمة ناقصة قبل البدء
        try? FileManager.default.removeItem(at: mp3URL)
        try? FileManager.default.removeItem(at: libURL)

        print("⬇️ Downloading: \(url)")
        URLSession.shared.downloadTask(with: remoteURL) { [weak self] tmpURL, _, error in
            guard let self, let tmpURL, error == nil else {
                print("❌ Download failed: \(error?.localizedDescription ?? "unknown")")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            do {
                // 1. احفظ في Documents/AlarmSounds (للتشغيل داخل التطبيق)
                if FileManager.default.fileExists(atPath: mp3URL.path) {
                    try FileManager.default.removeItem(at: mp3URL)
                }
                try FileManager.default.copyItem(at: tmpURL, to: mp3URL)
                print("✅ Saved to cache: \(mp3URL.lastPathComponent)")

                // 2. انسخ إلى Library/Sounds (لأصوات الإشعارات)
                self.copyToLibrarySounds(from: mp3URL, fileName: "\(fileName).mp3")

                DispatchQueue.main.async { completion(fileName) }
            } catch {
                print("❌ Save error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    // MARK: - نسخ إلى Library/Sounds

    @discardableResult
    func copyToLibrarySounds(from srcURL: URL, fileName: String) -> Bool {
        let destURL = librarySoundsDir.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            print("✅ Copied to Library/Sounds: \(fileName)")
            print("   Path: \(destURL.path)")
            return true
        } catch {
            print("❌ Library/Sounds copy failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - مسار الملف للتشغيل داخل التطبيق

    func localMP3URL(fileName: String) -> URL? {
        let url = cacheDir.appendingPathComponent("\(fileName).mp3")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - حذف عند حذف المنبه

    func deleteSound(fileName: String?) {
        guard let name = fileName else { return }
        try? FileManager.default.removeItem(
            at: cacheDir.appendingPathComponent("\(name).mp3"))
        try? FileManager.default.removeItem(
            at: librarySoundsDir.appendingPathComponent("\(name).mp3"))
    }

    func notificationSoundName(for alarm: Alarm) -> String? { nil }
}

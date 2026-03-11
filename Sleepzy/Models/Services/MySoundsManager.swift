import Foundation
import AVFoundation
import PhotosUI
import Combine

// ============================================================
// MARK: - MySound Model (أصوات المستخدم الشخصية — محلية فقط)
// ============================================================

struct MySound: Identifiable, Codable {
    let id:        String    // UUID محلي
    var name:      String
    let fileName:  String    // اسم الملف في Documents/MySounds/
    var duration:  Double
    let createdAt: Date

    // للتوافق مع SleepSound
    var previewURL: String {
        MySoundsManager.shared.localURL(for: self).absoluteString
    }

    var asSleepSound: SleepSound {
        SleepSound(
            id:       id,
            name:     name,
            category: .personal,        // تصنيف خاص بالأصوات الشخصية
            fileURL:  previewURL,
            coverURL: nil,
            duration: duration
        )
    }
}

// MARK: - MySoundsManager

class MySoundsManager: ObservableObject {

    static let shared = MySoundsManager()

    @Published var sounds: [MySound] = []
    @Published var isExtracting: Bool = false
    @Published var extractionProgress: Double = 0
    @Published var extractionError: String? = nil

    private let soundsDir: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MySounds", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private let metaKey = "my_sounds_metadata"

    init() { loadMetadata() }

    // MARK: - مسار الملف

    func localURL(for sound: MySound) -> URL {
        soundsDir.appendingPathComponent(sound.fileName)
    }

    // MARK: - استخراج الصوت من فيديو

    /// يقبل URL لفيديو محلي (من Camera Roll أو Files) ويستخرج الصوت منه
    // هل الملف صوت مباشر؟
    private func isAudioFile(_ url: URL) -> Bool {
        let audioExtensions = ["mp3", "m4a", "wav", "aiff", "aac", "flac"]
        return audioExtensions.contains(url.pathExtension.lowercased())
    }

    func extractAudio(from videoURL: URL, name: String) async {
        await MainActor.run {
            isExtracting = true
            extractionProgress = 0
            extractionError = nil
        }

        let soundId = UUID().uuidString

        // ✅ إذا كان الملف صوتاً مباشراً — احتفظ بالامتداد الأصلي
        if isAudioFile(videoURL) {
            let ext      = videoURL.pathExtension.lowercased()
            let fileName = "\(soundId).\(ext)"
            let destURL  = soundsDir.appendingPathComponent(fileName)

            do {
                try? FileManager.default.removeItem(at: destURL)
                try FileManager.default.copyItem(at: videoURL, to: destURL)

                var seconds: Double = 0
                if let audioPlayer = try? AVAudioPlayer(contentsOf: destURL) {
                    seconds = audioPlayer.duration
                }

                let sound = MySound(
                    id: soundId, name: name.isEmpty ? "My Sound" : name,
                    fileName: fileName, duration: seconds, createdAt: Date()
                )
                await MainActor.run {
                    self.sounds.append(sound)
                    self.saveMetadata()
                    self.isExtracting       = false
                    self.extractionProgress = 1.0
                }
                print("✅ Audio copied: \(fileName) (\(Int(seconds))s)")
            } catch {
                await MainActor.run {
                    self.extractionError = error.localizedDescription
                    self.isExtracting    = false
                }
            }
            return
        }

        // ✅ فيديو — استخرج الصوت وحفظه كـ m4a
        let fileName = "\(soundId).m4a"
        let destURL  = soundsDir.appendingPathComponent(fileName)

        do {
            let asset    = AVURLAsset(url: videoURL)
            let duration = try await asset.load(.duration)
            let seconds  = CMTimeGetSeconds(duration)

            guard let exporter = AVAssetExportSession(
                asset: asset, presetName: AVAssetExportPresetAppleM4A
            ) else {
                throw NSError(domain: "MySounds", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Cannot create exporter"])
            }

            exporter.outputURL      = destURL
            exporter.outputFileType = .m4a
            exporter.audioTimePitchAlgorithm = .spectral

            let progressTask = Task {
                while !Task.isCancelled {
                    await MainActor.run { self.extractionProgress = Double(exporter.progress) }
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }

            await exporter.export()
            progressTask.cancel()

            if exporter.status == .completed {
                let sound = MySound(
                    id: soundId, name: name.isEmpty ? "My Sound" : name,
                    fileName: fileName,
                    duration: seconds.isFinite ? seconds : 0,
                    createdAt: Date()
                )
                await MainActor.run {
                    self.sounds.append(sound)
                    self.saveMetadata()
                    self.isExtracting       = false
                    self.extractionProgress = 1.0
                }
                print("✅ Audio extracted: \(fileName) (\(Int(seconds))s)")
            } else {
                throw exporter.error ?? NSError(
                    domain: "MySounds", code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Export failed: \(exporter.status.rawValue)"]
                )
            }
        } catch {
            await MainActor.run {
                self.extractionError = error.localizedDescription
                self.isExtracting    = false
            }
            print("❌ Extraction error: \(error)")
        }
    }

    // MARK: - إعادة تسمية

    func rename(_ sound: MySound, to newName: String) {
        guard let i = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
        sounds[i].name = newName
        saveMetadata()
    }

    // MARK: - حذف

    func delete(_ sound: MySound) {
        // أوقف التشغيل إذا كان هذا الصوت يعزف الآن
        if SleepSoundPlayer.shared.currentSound?.id == sound.id {
            SleepSoundPlayer.shared.stop()
        }
        try? FileManager.default.removeItem(at: localURL(for: sound))
        sounds.removeAll { $0.id == sound.id }
        saveMetadata()
    }

    // MARK: - Persistence

    private func saveMetadata() {
        if let data = try? JSONEncoder().encode(sounds) {
            UserDefaults.standard.set(data, forKey: metaKey)
        }
    }

    private func loadMetadata() {
        guard let data = UserDefaults.standard.data(forKey: metaKey),
              let decoded = try? JSONDecoder().decode([MySound].self, from: data)
        else { return }
        // تحقق أن الملفات موجودة فعلاً
        sounds = decoded.filter {
            FileManager.default.fileExists(atPath: localURL(for: $0).path)
        }
    }
}

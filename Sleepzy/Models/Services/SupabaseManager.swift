import Foundation
import Supabase
import Combine

// ============================================================
// MARK: - SleepSound Model
// ============================================================

struct SleepSound: Identifiable, Codable, Equatable, Hashable {
    let id:        String
    let name:      String
    let category:  SoundCategory
    let fileURL:   String
    let coverURL:  String?
    let duration:  Double

    enum SoundCategory: String, Codable, CaseIterable, Hashable {
        case nature     = "Nature"
        case whiteNoise = "White Noise"
        case space      = "Space"
        case rain       = "Rain"
        case ocean      = "Ocean"
        case personal   = "My Sound"  // للأصوات الشخصية فقط

        // للـ category chips — بدون personal
        static var libraryCategories: [SoundCategory] {
            [.nature, .whiteNoise, .space, .rain, .ocean]
        }

        var dbValue: String {
            switch self {
            case .nature:     return "nature"
            case .whiteNoise: return "white_noise"
            case .space:      return "space"
            case .rain:       return "rain"
            case .ocean:      return "ocean"
            case .personal:   return "personal"
            }
        }

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            switch raw {
            case "nature":      self = .nature
            case "white_noise": self = .whiteNoise
            case "space":       self = .space
            case "rain":        self = .rain
            case "ocean":       self = .ocean
            default:            self = .nature
            }
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.singleValueContainer()
            try c.encode(dbValue)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category, duration
        case fileURL  = "file_url"
        case coverURL = "cover_url"
    }

    var previewURL: String { fileURL }
}

// MARK: - SupabaseManager

class SupabaseManager: ObservableObject {

    static let shared = SupabaseManager()

    @Published var sounds:     [SleepSound] = []
    @Published var byCategory: [SleepSound.SoundCategory: [SleepSound]] = [:]
    @Published var isLoading:  Bool = false
    @Published var error:      String? = nil

    // Supabase client من SupabaseService الموجود في المشروع
    private var db: SupabaseClient { SupabaseService.shared.client }

    // كاش الـ metadata في UserDefaults
    private let cacheKey = "supabase_sounds_v1"

    // مجلد ملفات الـ audio المحمّلة
    private let audioDir: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SleepAudio", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init() { loadMetaCache() }

    // MARK: - Fetch من Supabase

    func fetchSounds() async {
        await MainActor.run { isLoading = true; error = nil }

        do {
            let result: [SleepSound] = try await db
                .from("sleep_sounds")
                .select()
                .order("name")
                .execute()
                .value

            await MainActor.run {
                self.sounds     = result
                self.byCategory = Dictionary(grouping: result, by: \.category)
                self.isLoading  = false
            }

            // احفظ في الكاش
            if let data = try? JSONEncoder().encode(result) {
                UserDefaults.standard.set(data, forKey: cacheKey)
            }

        } catch {
            await MainActor.run {
                self.error     = error.localizedDescription
                self.isLoading = false
            }
            print("❌ Supabase fetch error: \(error)")
        }
    }

    func fetchIfNeeded() async {
        if sounds.isEmpty { await fetchSounds() }
    }

    // MARK: - Audio Cache

    func audioURL(for sound: SleepSound) -> URL {
        audioDir.appendingPathComponent("\(sound.id).mp3")
    }

    func isAudioCached(sound: SleepSound) -> Bool {
        FileManager.default.fileExists(atPath: audioURL(for: sound).path)
    }

    func downloadAudio(for sound: SleepSound) async throws -> URL {
        let dest = audioURL(for: sound)
        if FileManager.default.fileExists(atPath: dest.path) { return dest }

        guard let url = URL(string: sound.fileURL) else { throw URLError(.badURL) }

        let (tmp, _) = try await URLSession.shared.download(from: url)
        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        try FileManager.default.moveItem(at: tmp, to: dest)
        print("✅ Audio cached: \(sound.name)")
        return dest
    }

    // MARK: - Meta Cache

    private func loadMetaCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode([SleepSound].self, from: data)
        else { return }
        sounds     = decoded
        byCategory = Dictionary(grouping: decoded, by: \.category)
    }
}

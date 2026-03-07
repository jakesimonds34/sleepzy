/*
import Foundation
import AVFoundation
import Combine

// MARK: - Models

struct SleepSound: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let category: SoundCategory
    let previewURL: String
    let imageURL: String?
    let duration: Double
    let username: String

    enum SoundCategory: String, Codable, CaseIterable {
        case nature     = "Nature"
        case whiteNoise = "White Noise"
        case space      = "Space"

        var searchQuery: String {
            switch self {
            case .nature:     return "rain forest ocean nature ambient"
            case .whiteNoise: return "brown noise white noise pink noise"
            case .space:      return "space ambient deep cosmos"
            }
        }
    }
}

// MARK: - Freesound API Response Models

struct FreesoundSearchResponse: Codable {
    let count: Int
    let results: [FreesoundSound]
}

struct FreesoundSound: Codable {
    let id: Int
    let name: String
    let duration: Double
    let username: String
    let previews: FreesoundPreviews?
    let images: FreesoundImages?
    let tags: [String]

    struct FreesoundPreviews: Codable {
        let previewHqMp3: String?
        let previewLqMp3: String?
        enum CodingKeys: String, CodingKey {
            case previewHqMp3 = "preview-hq-mp3"
            case previewLqMp3 = "preview-lq-mp3"
        }
    }
    struct FreesoundImages: Codable {
        let waveformM: String?
        let spectralM: String?
        enum CodingKeys: String, CodingKey {
            case waveformM = "waveform_m"
            case spectralM = "spectral_m"
        }
    }
}

// MARK: - Category Load State

enum CategoryLoadState {
    case idle
    case loading
    case loaded([SleepSound])
    case failed(String)

    var sounds: [SleepSound]? {
        if case .loaded(let s) = self { return s }
        return nil
    }
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    var error: String? {
        if case .failed(let e) = self { return e }
        return nil
    }
}

// MARK: - FreesoundAPIManager

class FreesoundAPIManager: ObservableObject {

    static let shared = FreesoundAPIManager()

    private let apiKey: String = "a1nDheXjbaSHQUyms410agH7QaCHBA1Ga38qCrps"
    private let baseURL = "https://freesound.org/apiv2"

    // Cache keys
    private let cacheKeyAll        = "cache_sounds_all"
    private let cacheKeyNature     = "cache_sounds_nature"
    private let cacheKeyWhiteNoise = "cache_sounds_whitenoise"
    private let cacheKeySpace      = "cache_sounds_space"

    @Published var stateAll:        CategoryLoadState = .idle
    @Published var stateNature:     CategoryLoadState = .idle
    @Published var stateWhiteNoise: CategoryLoadState = .idle
    @Published var stateSpace:      CategoryLoadState = .idle

    private var pageAll        = 1
    private var pageNature     = 1
    private var pageWhiteNoise = 1
    private var pageSpace      = 1

    init() {
        // عند أول إطلاق: حمّل الـ cache من UserDefaults فوراً
        loadCache()
    }

    // MARK: - Cache — UserDefaults

    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKeyAll),
           let sounds = try? JSONDecoder().decode([SleepSound].self, from: data), !sounds.isEmpty {
            stateAll = .loaded(sounds)
        }
        if let data = UserDefaults.standard.data(forKey: cacheKeyNature),
           let sounds = try? JSONDecoder().decode([SleepSound].self, from: data), !sounds.isEmpty {
            stateNature = .loaded(sounds)
        }
        if let data = UserDefaults.standard.data(forKey: cacheKeyWhiteNoise),
           let sounds = try? JSONDecoder().decode([SleepSound].self, from: data), !sounds.isEmpty {
            stateWhiteNoise = .loaded(sounds)
        }
        if let data = UserDefaults.standard.data(forKey: cacheKeySpace),
           let sounds = try? JSONDecoder().decode([SleepSound].self, from: data), !sounds.isEmpty {
            stateSpace = .loaded(sounds)
        }
    }

    private func saveCache(_ sounds: [SleepSound], for category: SleepSound.SoundCategory?) {
        let key: String
        switch category {
        case .none:        key = cacheKeyAll
        case .nature:      key = cacheKeyNature
        case .whiteNoise:  key = cacheKeyWhiteNoise
        case .space:       key = cacheKeySpace
        }
        if let data = try? JSONEncoder().encode(sounds) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Public API

    func state(for category: SleepSound.SoundCategory?) -> CategoryLoadState {
        switch category {
        case .none:        return stateAll
        case .nature:      return stateNature
        case .whiteNoise:  return stateWhiteNoise
        case .space:       return stateSpace
        }
    }

    func loadIfNeeded(for category: SleepSound.SoundCategory?) {
        // حمّل فقط إذا كانت الحالة idle (لا cache ولا تحميل جارٍ)
        if case .idle = state(for: category) {
            load(category: category, page: 1, appending: false)
        }
    }

    func reload(for category: SleepSound.SoundCategory?) {
        resetPage(for: category)
        load(category: category, page: 1, appending: false)
    }

    func loadMore(for category: SleepSound.SoundCategory?) {
        guard !state(for: category).isLoading else { return }
        guard case .loaded(_) = state(for: category) else { return }
        let nextPage = currentPage(for: category) + 1
        setPage(nextPage, for: category)
        load(category: category, page: nextPage, appending: true)
    }

    // MARK: - Core Load

    private func load(category: SleepSound.SoundCategory?, page: Int, appending: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.setState(.loading, for: category)
        }
        if category == nil {
            fetchAllCategories(page: page, appending: appending)
        } else {
            fetchSingleCategory(category!, page: page, appending: appending)
        }
    }

    private func fetchAllCategories(page: Int, appending: Bool) {
        let cats: [SleepSound.SoundCategory] = [.nature, .whiteNoise, .space]
        let group = DispatchGroup()
        var gathered: [SleepSound] = []
        var firstError: String? = nil
        let lock = NSLock()

        for cat in cats {
            group.enter()
            fetchRaw(query: cat.searchQuery, page: page, pageSize: 5) { [weak self] result in
                lock.lock()
                switch result {
                case .success(let raw):
                    let mapped = raw.compactMap { self?.map($0, category: cat) }
                    gathered.append(contentsOf: mapped)
                case .failure(let err):
                    if firstError == nil { firstError = self?.friendlyError(err) }
                }
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if gathered.isEmpty, let err = firstError {
                let existing = self.stateAll.sounds ?? []
                self.stateAll = existing.isEmpty ? .failed(err) : .loaded(existing)
            } else {
                let sorted = gathered.sorted { $0.category.rawValue < $1.category.rawValue }
                let final = appending ? (self.stateAll.sounds ?? []) + sorted : sorted
                self.stateAll = .loaded(final)
                self.saveCache(final, for: nil)
            }
        }
    }

    private func fetchSingleCategory(_ category: SleepSound.SoundCategory, page: Int, appending: Bool) {
        fetchRaw(query: category.searchQuery, page: page, pageSize: 15) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let raw):
                    let mapped = raw.compactMap { self.map($0, category: category) }
                    let final = appending ? (self.state(for: category).sounds ?? []) + mapped : mapped
                    self.setState(.loaded(final), for: category)
                    self.saveCache(final, for: category)
                case .failure(let err):
                    let msg = self.friendlyError(err)
                    if appending {
                        let existing = self.state(for: category).sounds ?? []
                        self.setState(.loaded(existing), for: category)
                    } else {
                        self.setState(.failed(msg), for: category)
                    }
                }
            }
        }
    }

    private func fetchRaw(
        query: String,
        page: Int,
        pageSize: Int,
        completion: @escaping (Result<[FreesoundSound], Error>) -> Void
    ) {
        var components = URLComponents(string: "\(baseURL)/search/text/")!
        components.queryItems = [
            URLQueryItem(name: "query",     value: query),
            URLQueryItem(name: "filter",    value: "duration:[10 TO 600]"),
            URLQueryItem(name: "sort",      value: "rating_desc"),
            URLQueryItem(name: "fields",    value: "id,name,duration,username,previews,images,tags"),
            URLQueryItem(name: "page_size", value: "\(pageSize)"),
            URLQueryItem(name: "page",      value: "\(page)"),
            URLQueryItem(name: "token",     value: apiKey),
        ]
        guard let url = components.url else {
            completion(.failure(URLError(.badURL))); return
        }

        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error { completion(.failure(error)); return }

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                completion(.failure(NSError(domain: "Freesound", code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Server error \(http.statusCode)"])))
                return
            }
            guard let data else { completion(.failure(URLError(.zeroByteResource))); return }
            do {
                let decoded = try JSONDecoder().decode(FreesoundSearchResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Helpers

    private func map(_ sound: FreesoundSound, category: SleepSound.SoundCategory) -> SleepSound? {
        guard let preview = sound.previews?.previewHqMp3 ?? sound.previews?.previewLqMp3 else { return nil }
        return SleepSound(
            id: sound.id,
            name: sound.name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            previewURL: preview,
            imageURL: sound.images?.spectralM ?? sound.images?.waveformM,
            duration: sound.duration,
            username: sound.username
        )
    }

    private func setState(_ state: CategoryLoadState, for category: SleepSound.SoundCategory?) {
        switch category {
        case .none:        stateAll        = state
        case .nature:      stateNature     = state
        case .whiteNoise:  stateWhiteNoise = state
        case .space:       stateSpace      = state
        }
    }

    private func currentPage(for category: SleepSound.SoundCategory?) -> Int {
        switch category {
        case .none:        return pageAll
        case .nature:      return pageNature
        case .whiteNoise:  return pageWhiteNoise
        case .space:       return pageSpace
        }
    }

    private func setPage(_ page: Int, for category: SleepSound.SoundCategory?) {
        switch category {
        case .none:        pageAll        = page
        case .nature:      pageNature     = page
        case .whiteNoise:  pageWhiteNoise = page
        case .space:       pageSpace      = page
        }
    }

    private func resetPage(for category: SleepSound.SoundCategory?) { setPage(1, for: category) }

    private func friendlyError(_ error: Error) -> String {
        if let urlErr = error as? URLError {
            switch urlErr.code {
            case .notConnectedToInternet: return "لا يوجد اتصال بالإنترنت"
            case .timedOut:               return "انتهت مهلة الطلب، حاول مجدداً"
            case .cannotFindHost:         return "تعذّر الوصول إلى freesound.org"
            default: break
            }
        }
        return error.localizedDescription
    }
}

// MARK: - SleepSoundPlayer

class SleepSoundPlayer: NSObject, ObservableObject {

    static let shared = SleepSoundPlayer()

    @Published var currentSound: SleepSound?
    @Published var isPlaying    = false
    @Published var isBuffering  = false
    @Published var volume: Float = 0.8

    // Progress
    @Published var currentTime: Double = 0   // seconds played
    @Published var duration:    Double = 0   // total seconds

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    var selectedAlarmSoundId:   Int?
    var selectedAlarmSoundName: String = "Brown Calm"
    var selectedAlarmSoundURL:  String = ""

    func play(sound: SleepSound) {
        guard !sound.previewURL.isEmpty else { return }
        stop()

        guard let url = URL(string: sound.previewURL) else { return }

        currentSound = sound
        isBuffering  = true
        isPlaying    = true
        currentTime  = 0
        duration     = sound.duration > 0 ? sound.duration : 0

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("Audio session: \(error)") }

        // AVPlayerItem مباشرة من URL — الطريقة الأبسط والأكثر توافقاً مع Freesound
        playerItem = AVPlayerItem(url: url)
        player     = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.play()

        // تحديث progress كل ربع ثانية
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let secs = CMTimeGetSeconds(time)
            if secs.isFinite && secs >= 0 { self.currentTime = secs }
        }

        // مراقبة status
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                if status == .readyToPlay {
                    self.isBuffering = false
                    if let d = self.playerItem?.duration, CMTimeGetSeconds(d).isFinite && CMTimeGetSeconds(d) > 0 {
                        self.duration = CMTimeGetSeconds(d)
                    }
                } else if status == .failed {
                    self.isBuffering = false
                    self.isPlaying   = false
                    print("AVPlayer error: \(self.playerItem?.error?.localizedDescription ?? "unknown")")
                }
            }
            .store(in: &cancellables)

        // مراقبة buffering
        playerItem?.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ok in self?.isBuffering = !ok }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self, selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime, object: playerItem
        )
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        // إزالة time observer أولاً
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player     = nil
        playerItem = nil
        currentSound = nil
        isPlaying    = false
        isBuffering  = false
        currentTime  = 0
        duration     = 0
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func toggle(sound: SleepSound) {
        if currentSound?.id == sound.id {
            if isPlaying { pause() } else { resume() }
        } else {
            play(sound: sound)
        }
    }

    func seek(to progress: Double) {
        guard duration > 0, let player else { return }
        let targetSeconds = progress * duration
        let time = CMTime(seconds: targetSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = targetSeconds
    }

    func setVolume(_ v: Float) {
        volume = v
        player?.volume = v
    }

    func selectForAlarm(_ sound: SleepSound) {
        selectedAlarmSoundId   = sound.id
        selectedAlarmSoundName = sound.name
        selectedAlarmSoundURL  = sound.previewURL
    }

    @objc private func playerDidFinish() {
        // Loop: رجوع للبداية
        player?.seek(to: .zero)
        player?.play()
        currentTime = 0
    }
}
*/

import Foundation
import AVFoundation
import Combine

// ============================================================
// MARK: - SleepSoundPlayer
// ملاحظة: SleepSound model موجود في SupabaseManager.swift
// ============================================================

class SleepSoundPlayer: NSObject, ObservableObject {

    static let shared = SleepSoundPlayer()

    @Published var currentSound: SleepSound?
    @Published var isPlaying    = false
    @Published var isBuffering  = false
    @Published var volume: Float = 0.8

    // Progress
    @Published var currentTime: Double = 0   // seconds played
    @Published var duration:    Double = 0   // total seconds

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    var selectedAlarmSoundId:   String?
    var selectedAlarmSoundName: String = ""
    var selectedAlarmSoundURL:  String = ""

    func play(sound: SleepSound) {
        guard !sound.previewURL.isEmpty else { return }
        stop()

        guard let url = URL(string: sound.previewURL) else { return }

        currentSound = sound
        isBuffering  = true
        isPlaying    = true
        currentTime  = 0
        duration     = sound.duration > 0 ? sound.duration : 0

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("Audio session: \(error)") }

        // AVPlayerItem مباشرة من URL — الطريقة الأبسط والأكثر توافقاً مع Freesound
        playerItem = AVPlayerItem(url: url)
        player     = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.play()

        // تحديث progress كل ربع ثانية
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let secs = CMTimeGetSeconds(time)
            if secs.isFinite && secs >= 0 { self.currentTime = secs }
        }

        // مراقبة status
        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                if status == .readyToPlay {
                    self.isBuffering = false
                    if let d = self.playerItem?.duration, CMTimeGetSeconds(d).isFinite && CMTimeGetSeconds(d) > 0 {
                        self.duration = CMTimeGetSeconds(d)
                    }
                } else if status == .failed {
                    self.isBuffering = false
                    self.isPlaying   = false
                    print("AVPlayer error: \(self.playerItem?.error?.localizedDescription ?? "unknown")")
                }
            }
            .store(in: &cancellables)

        // مراقبة buffering
        playerItem?.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ok in self?.isBuffering = !ok }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self, selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime, object: playerItem
        )
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        // إزالة time observer أولاً
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player     = nil
        playerItem = nil
        currentSound = nil
        isPlaying    = false
        isBuffering  = false
        currentTime  = 0
        duration     = 0
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func toggle(sound: SleepSound) {
        if currentSound?.id == sound.id {
            if isPlaying { pause() } else { resume() }
        } else {
            play(sound: sound)
        }
    }

    func seek(to progress: Double) {
        guard duration > 0, let player else { return }
        let targetSeconds = progress * duration
        let time = CMTime(seconds: targetSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = targetSeconds
    }

    func setVolume(_ v: Float) {
        volume = v
        player?.volume = v
    }

    func selectForAlarm(_ sound: SleepSound) {
        selectedAlarmSoundId   = sound.id
        selectedAlarmSoundName = sound.name
        selectedAlarmSoundURL  = sound.fileURL
    }

    // ✅ تشغيل ملف محلي (Supabase cache أو My Sounds)
    func playLocalFile(url: URL, sound: SleepSound) {
        stop()
        currentSound = sound
        isBuffering  = false
        isPlaying    = true
        currentTime  = 0
        duration     = sound.duration > 0 ? sound.duration : 0

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("AudioSession: \(error)") }

        playerItem = AVPlayerItem(url: url)
        player     = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.play()

        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let secs = CMTimeGetSeconds(time)
            if secs.isFinite && secs >= 0 { self.currentTime = secs }
        }

        playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                if status == .readyToPlay {
                    if let d = self.playerItem?.duration,
                       CMTimeGetSeconds(d).isFinite && CMTimeGetSeconds(d) > 0 {
                        self.duration = CMTimeGetSeconds(d)
                    }
                } else if status == .failed {
                    self.isPlaying = false
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self, selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime, object: playerItem
        )
    }

    @objc private func playerDidFinish() {
        // Loop: رجوع للبداية
        player?.seek(to: .zero)
        player?.play()
        currentTime = 0
    }
}

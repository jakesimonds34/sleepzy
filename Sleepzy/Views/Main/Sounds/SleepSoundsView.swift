import SwiftUI
import AVFoundation
import PhotosUI
import UniformTypeIdentifiers

// ============================================================
// MARK: - SleepSoundsView
// ============================================================

struct SleepSoundsView: View {

    @Binding var selection: Taps

    @StateObject private var supabase = SupabaseManager.shared
    @StateObject private var mySounds = MySoundsManager.shared
    @StateObject private var player   = SleepSoundPlayer.shared

    @State private var selectedTab: SoundTab = .library
    @State private var selectedCategory: SleepSound.SoundCategory? = nil
    @State private var showAddMySound = false

    var alarmSelectionMode: Bool = false
    var onSoundSelected: ((SleepSound) -> Void)? = nil

    enum SoundTab { case library, mine }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            AppHeaderView(title: "Sleep Sounds", subTitle: "", paddingTop: 0)
                .padding(.horizontal)

            // Tab: Library / My Sounds
            tabPicker
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            if selectedTab == .library {
                libraryTab
            } else {
                mySoundsTab
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if player.currentSound != nil {
                miniPlayerBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8),
                               value: player.currentSound != nil)
            }
        }
        .background(
            MyImage(source: .asset(.bgSounds))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .task { await supabase.fetchIfNeeded() }
        .sheet(isPresented: $showAddMySound) {
            AddMySoundView()
        }
    }

    // MARK: - Tab Picker

    var tabPicker: some View {
        HStack(spacing: 0) {
            tabBtn(title: "Library",   tab: .library, icon: "music.note.list")
            tabBtn(title: "My Sounds", tab: .mine,    icon: "person.fill")
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func tabBtn(title: String, tab: SoundTab, icon: String) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } }) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedTab == tab
                          ? Color(red: 0.42, green: 0.31, blue: 0.85).opacity(0.5)
                          : Color.clear)
                    .padding(3)
            )
        }
    }

    // MARK: - Library Tab

    var libraryTab: some View {
        VStack(spacing: 0) {
            categoryChips.padding(.bottom, 12)

            if supabase.isLoading && supabase.sounds.isEmpty {
                loadingView
            } else if let err = supabase.error, supabase.sounds.isEmpty {
                errorView(message: err)
            } else {
                let filtered = filteredSounds
                if filtered.isEmpty {
                    emptyView
                } else {
                    soundsList(sounds: filtered)
                }
            }
        }
    }

    var filteredSounds: [SleepSound] {
        guard let cat = selectedCategory else { return supabase.sounds }
        return supabase.byCategory[cat] ?? []
    }

    var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chipButton(label: "All", isSelected: selectedCategory == nil) {
                    withAnimation { selectedCategory = nil }
                }
                ForEach(SleepSound.SoundCategory.libraryCategories, id: \.self) { cat in
                    chipButton(label: cat.rawValue, isSelected: selectedCategory == cat) {
                        withAnimation { selectedCategory = cat }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accent.opacity(0.1) : .white.opacity(0.05))
                        .overlay(Capsule().strokeBorder(
                            isSelected ? Color(hex: "988AE1").opacity(0.4) : Color.white.opacity(0.2),
                            lineWidth: 1))
                )
        }
    }

    // MARK: - My Sounds Tab

    var mySoundsTab: some View {
        VStack(spacing: 0) {
            // Add button
            Button(action: { showAddMySound = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 16))
                    Text("Add from Video").font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.42, green: 0.31, blue: 0.85),
                                 Color(red: 0.27, green: 0.18, blue: 0.65)],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }

            if mySounds.sounds.isEmpty {
                mySoundsEmptyView
            } else {
                soundsList(sounds: mySounds.sounds.map { $0.asSleepSound })
            }
        }
    }

    var mySoundsEmptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "waveform.badge.plus")
                .font(.system(size: 52)).foregroundColor(.white.opacity(0.18))
            VStack(spacing: 8) {
                Text("No personal sounds yet")
                    .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Text("Extract audio from any video on\nyour device and add it here")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sounds List

    func soundsList(sounds: [SleepSound]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(sounds) { sound in
                    SoundRowView(
                        sound: sound,
                        alarmSelectionMode: alarmSelectionMode,
                        isMine: mySounds.sounds.contains { $0.id == sound.id },
                        onSelectForAlarm: {
                            player.selectForAlarm(sound)
                            onSoundSelected?(sound)
                        },
                        onDelete: {
                            if let mine = mySounds.sounds.first(where: { $0.id == sound.id }) {
                                mySounds.delete(mine)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 24)
        }
    }

    // MARK: - State Views

    var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().scaleEffect(1.4).tint(.white.opacity(0.6))
            Text("Loading sounds…")
                .font(.system(size: 15)).foregroundColor(.white.opacity(0.45))
            Spacer()
        }.frame(maxWidth: .infinity)
    }

    var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 48)).foregroundColor(.white.opacity(0.2))
            Text("No sounds in this category")
                .font(.system(size: 16)).foregroundColor(.white.opacity(0.45))
            Spacer()
        }.frame(maxWidth: .infinity)
    }

    func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48)).foregroundColor(.white.opacity(0.25))
            Text("Failed to load sounds")
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
            Text(message)
                .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            Button(action: { Task { await supabase.fetchSounds() } }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32).padding(.vertical, 12)
                .background(Color(red: 0.35, green: 0.25, blue: 0.75))
                .cornerRadius(22)
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Mini Player

    var miniPlayerBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.2, green: 0.15, blue: 0.45))
                        .frame(width: 44, height: 44)
                    if player.isBuffering {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else if player.isPlaying {
                        WaveformAnimationView().frame(width: 24, height: 18)
                    } else {
                        Image(systemName: "waveform")
                            .font(.system(size: 16)).foregroundColor(.white.opacity(0.6))
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(player.currentSound?.name ?? "")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                    Text(formatTime(player.currentTime) + " / " + formatTime(player.duration))
                        .font(.system(size: 11)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Button(action: { player.setVolume(max(0, player.volume - 0.2)) }) {
                    Image(systemName: "speaker.fill").font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5)).frame(width: 30, height: 30)
                }
                Button(action: { if player.isPlaying { player.pause() } else { player.resume() } }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                Button(action: { player.setVolume(min(1, player.volume + 0.2)) }) {
                    Image(systemName: "speaker.wave.3.fill").font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5)).frame(width: 30, height: 30)
                }
                Button(action: { player.stop() }) {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6)).frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1)).clipShape(Circle())
                }
            }
            .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 4)

            Slider(value: Binding(get: { player.progress }, set: { player.seek(to: $0) }), in: 0...1)
                .tint(Color(red: 0.5, green: 0.4, blue: 0.9))
                .padding(.horizontal, 16).padding(.bottom, 10)
        }
        .background(ZStack {
            Color(red: 0.10, green: 0.08, blue: 0.28).opacity(0.97)
            Rectangle().fill(.ultraThinMaterial).opacity(0.3)
        })
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
        }
    }

    func formatTime(_ s: Double) -> String {
        guard s.isFinite && s >= 0 else { return "0:00" }
        let t = Int(s); return "\(t/60):\(String(format: "%02d", t%60))"
    }
}

// MARK: - SoundRowView

struct SoundRowView: View {
    let sound: SleepSound
    var alarmSelectionMode: Bool = false
    var isMine: Bool = false
    var onSelectForAlarm: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @StateObject private var player   = SleepSoundPlayer.shared
    @State private var isDownloading  = false
    private let supabase = SupabaseManager.shared

    private var isPlaying:   Bool { player.currentSound?.id == sound.id && player.isPlaying }
    private var isBuffering: Bool { player.currentSound?.id == sound.id && player.isBuffering }
    private var isSelected:  Bool { player.selectedAlarmSoundId == sound.id }
    private var isCached:    Bool { isMine || supabase.isAudioCached(sound: sound) }

    var body: some View {
        HStack(spacing: 14) {
            soundThumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(sound.name)
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                if sound.category != .personal {
                    Text(sound.category.rawValue)
                        .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
                }
                Text(formatDuration(sound.duration))
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                if alarmSelectionMode && isSelected {
                    Text("Selected for alarm ✓")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.9, blue: 0.6))
                }
            }

            Spacer()

            HStack(spacing: 10) {
                // زر الاختيار للمنبه
                if alarmSelectionMode {
                    Button(action: { onSelectForAlarm?() }) {
                        Image(systemName: isSelected ? "alarm.fill" : "alarm")
                            .font(.system(size: 16))
                            .foregroundColor(isSelected
                                ? Color(red: 0.5, green: 0.9, blue: 0.6) : .white.opacity(0.4))
                    }
                }

                // زر الحذف (My Sounds فقط)
                if isMine && !alarmSelectionMode {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(width: 30, height: 30)
                    }
                }

                // زر التشغيل
                Button(action: { handlePlay() }) {
                    if isBuffering || isDownloading {
                        ProgressView().tint(.white).frame(width: 32, height: 32)
                    } else {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 32, height: 32)
                    }
                }
                .disabled(isDownloading)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isPlaying ? AppTheme.accent.opacity(0.1) : .white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isPlaying ? Color(hex: "988AE1").opacity(0.8) : .clear, lineWidth: 1))
        )
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }

    func handlePlay() {
        if player.currentSound?.id == sound.id {
            if player.isPlaying { player.pause() } else { player.resume() }
            return
        }

        // إذا كان الصوت من My Sounds أو محمّلاً مسبقاً
        if isMine {
            let url = MySoundsManager.shared.localURL(
                for: MySoundsManager.shared.sounds.first { $0.id == sound.id }!
            )
            player.playLocalFile(url: url, sound: sound)
            return
        }

        // إذا كان في الـ Cache
        let cachedURL = supabase.audioURL(for: sound)
        if FileManager.default.fileExists(atPath: cachedURL.path) {
            player.playLocalFile(url: cachedURL, sound: sound)
            return
        }

        // حمّل من Supabase أولاً
        isDownloading = true
        Task {
            do {
                let url = try await supabase.downloadAudio(for: sound)
                await MainActor.run {
                    isDownloading = false
                    player.playLocalFile(url: url, sound: sound)
                }
            } catch {
                await MainActor.run { isDownloading = false }
                print("Download failed: \(error)")
            }
        }
    }

    func formatDuration(_ s: Double) -> String {
        guard s > 0 else { return "" }
        let t = Int(s)
        return t < 60 ? "\(t)s" : "\(t/60)m \(t%60)s"
    }

    var soundThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(categoryGradient).frame(width: 60, height: 60)

            if let coverURL = sound.coverURL, let url = URL(string: coverURL) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else { categoryIcon }
                }
            } else { categoryIcon }

            if isPlaying {
                RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.35)).frame(width: 60, height: 60)
                WaveformAnimationView().frame(width: 32, height: 24)
            }

            if !isCached && !isMine {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(4)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .offset(x: 20, y: 20)
            }
        }
    }

    var categoryGradient: LinearGradient {
        switch sound.category {
        case .nature:
            return LinearGradient(colors: [Color(red:0.1,green:0.45,blue:0.3), Color(red:0.05,green:0.3,blue:0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .whiteNoise:
            return LinearGradient(colors: [Color(red:0.35,green:0.2,blue:0.55), Color(red:0.5,green:0.3,blue:0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .space:
            return LinearGradient(colors: [Color(red:0.1,green:0.1,blue:0.35), Color(red:0.2,green:0.15,blue:0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rain:
            return LinearGradient(colors: [Color(red:0.1,green:0.25,blue:0.5), Color(red:0.05,green:0.15,blue:0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ocean:
            return LinearGradient(colors: [Color(red:0.05,green:0.3,blue:0.5), Color(red:0.05,green:0.2,blue:0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .personal:
            return LinearGradient(colors: [Color(red:0.25,green:0.22,blue:0.48), Color(red:0.18,green:0.15,blue:0.38)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var categoryIcon: some View {
        Group {
            switch sound.category {
            case .nature:     Image(systemName: "leaf.fill")
            case .whiteNoise: Image(systemName: "waveform.path")
            case .space:      Image(systemName: "sparkles")
            case .rain:       Image(systemName: "cloud.rain.fill")
            case .ocean:      Image(systemName: "water.waves")
            case .personal:   Image(systemName: "music.note")
            }
        }
        .font(.system(size: 22)).foregroundColor(.white.opacity(0.7))
    }
}

// MARK: - AddMySoundView

struct AddMySoundView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mySounds = MySoundsManager.shared

    @State private var soundName        = ""
    @State private var showVideoPicker  = false
    @State private var videoSource: VideoSource = .photoLibrary
    @State private var selectedVideoURL: URL? = nil

    enum VideoSource { case photoLibrary, files }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.04, blue: 0.18).ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ثابت في الأعلى ──
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Add Sound")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.08))

                // ── المحتوى ──
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // اسم الصوت
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SOUND NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.45)).tracking(1)
                            TextField("e.g. Morning Birds", text: $soundName)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16).padding(.vertical, 14)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                                .tint(Color(red: 0.5, green: 0.4, blue: 0.9))
                        }

                        // اختيار مصدر الملف
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SELECT FILE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.45)).tracking(1)
                            HStack(spacing: 12) {
                                videoSourceButton(title: "Camera Roll", icon: "photo.on.rectangle") {
                                    videoSource = .photoLibrary; showVideoPicker = true
                                }
                                videoSourceButton(title: "Files", icon: "folder.fill") {
                                    videoSource = .files; showVideoPicker = true
                                }
                            }
                            Text("Supports video and audio files (mp3, m4a, wav…)")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.35))
                        }

                        // الفيديو المختار
                        if let url = selectedVideoURL {
                            selectedVideoCard(url: url)
                        }

                        // شريط التقدم
                        if mySounds.isExtracting {
                            extractionProgressView
                        }

                        // خطأ
                        if let err = mySounds.extractionError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                                Text(err)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .padding(14)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // زر الاستخراج
                        if selectedVideoURL != nil && !mySounds.isExtracting {
                            Button(action: startExtraction) {
                                HStack(spacing: 10) {
                                    Image(systemName: "waveform.badge.plus").font(.system(size: 17))
                                    Text("Extract Audio").font(.system(size: 17, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.48, green: 0.36, blue: 0.91),
                                                 Color(red: 0.29, green: 0.20, blue: 0.69)],
                                        startPoint: .leading, endPoint: .trailing
                                    ).clipShape(RoundedRectangle(cornerRadius: 16))
                                )
                                .shadow(color: Color(red: 0.42, green: 0.31, blue: 0.85).opacity(0.45),
                                        radius: 12, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showVideoPicker) {
            if videoSource == .photoLibrary {
                VideoPicker(selectedURL: $selectedVideoURL)
            } else {
                DocumentVideoPicker(selectedURL: $selectedVideoURL)
            }
        }
    }

    func videoSourceButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 16))
                Text(title).font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
        }
    }

    // هل الملف المختار صوت مباشر (بدون حاجة للاستخراج)؟
    private func isAudioFile(_ url: URL) -> Bool {
        let audioExtensions = ["mp3", "m4a", "wav", "aiff", "aac", "flac", "ogg"]
        return audioExtensions.contains(url.pathExtension.lowercased())
    }

    func selectedVideoCard(url: URL) -> some View {
        let isAudio = isAudioFile(url)
        return HStack(spacing: 12) {
            Image(systemName: isAudio ? "music.note" : "film.fill")
                .font(.system(size: 20)).foregroundColor(.white.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(isAudio
                    ? Color(red: 0.2, green: 0.5, blue: 0.4)
                    : Color(red: 0.3, green: 0.2, blue: 0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(url.lastPathComponent)
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.white).lineLimit(1)
                Text(isAudio ? "Audio file — ready to add" : "Video — audio will be extracted")
                    .font(.system(size: 12)).foregroundColor(Color(red: 0.5, green: 0.9, blue: 0.6))
            }
            Spacer()
            Button(action: { selectedVideoURL = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20)).foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    var extractionProgressView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Processing audio…")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("\(Int(mySounds.extractionProgress * 100))%")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            }
            ProgressView(value: mySounds.extractionProgress)
                .tint(Color(red: 0.5, green: 0.4, blue: 0.9))
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func startExtraction() {
        guard let url = selectedVideoURL else { return }
        Task {
            // ✅ صوت مباشر → انسخه مباشرة بدون استخراج
            // ✅ فيديو → استخرج الصوت منه
            await mySounds.extractAudio(from: url, name: soundName)
            if mySounds.extractionError == nil {
                await MainActor.run { dismiss() }
            }
        }
    }
}

// MARK: - VideoPicker (Camera Roll)

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes    = ["public.movie"]
        picker.delegate      = context.coordinator
        picker.videoQuality  = .typeHigh
        return picker
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPicker
        init(_ p: VideoPicker) { parent = p }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.selectedURL = url
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - DocumentVideoPicker (Files app — video + audio)

struct DocumentVideoPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // ✅ يقبل فيديو وصوت معاً
        let types: [UTType] = [
            .movie, .video, .mpeg4Movie, .quickTimeMovie,
            .audio, .mp3, .wav, .aiff,
            UTType("public.audio") ?? .audio,
            UTType("com.apple.m4a-audio") ?? .audio
        ]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate               = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentVideoPicker
        init(_ p: DocumentVideoPicker) { parent = p }

        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            _ = url.startAccessingSecurityScopedResource()
            parent.selectedURL = url
        }
    }
}

// MARK: - Waveform + Stars (مشتركة)

struct WaveformAnimationView: View {
    @State private var phase = false
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<4, id: \.self) { i in
                Capsule().fill(Color.white)
                    .frame(width: 3, height: phase ? [18.0,10.0,22.0,12.0][i] : [8.0,20.0,6.0,18.0][i])
                    .animation(.easeInOut(duration: 0.4 + Double(i)*0.1).repeatForever(autoreverses: true).delay(Double(i)*0.08), value: phase)
            }
        }
        .onAppear { phase = true }
    }
}

struct StarsBackgroundView: View {
    let stars: [StarParticle] = (0..<80).map { _ in
        StarParticle(x: .random(in:0...1), y: .random(in:0...0.5),
                     size: .random(in:1...2.5), opacity: .random(in:0.2...0.7))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(stars) { star in
                Circle().fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
            }
        }
    }
}

struct StarParticle: Identifiable {
    let id = UUID(); let x, y, size: CGFloat; let opacity: Double
}

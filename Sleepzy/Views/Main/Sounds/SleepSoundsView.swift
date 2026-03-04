import SwiftUI

// MARK: - SleepSoundsView

struct SleepSoundsView: View {

    @Binding var selection: Taps

    @StateObject private var api    = FreesoundAPIManager.shared
    @StateObject private var player = SleepSoundPlayer.shared

    @State private var selectedCategory: SleepSound.SoundCategory? = nil

    var alarmSelectionMode: Bool = false
    var onSoundSelected: ((SleepSound) -> Void)? = nil

    var currentState: CategoryLoadState { api.state(for: selectedCategory) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.16),
                    Color(red: 0.07, green: 0.07, blue: 0.24),
                    Color(red: 0.09, green: 0.05, blue: 0.30)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            StarsBackgroundView().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Sleep Sounds")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                categoryChips.padding(.bottom, 16)

                contentForState(currentState)
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
        .onAppear {
            api.loadIfNeeded(for: selectedCategory)
        }
        .onChange(of: selectedCategory) { newCat in
            api.loadIfNeeded(for: newCat)
        }
    }

    // MARK: - Content Switch

    @ViewBuilder
    func contentForState(_ state: CategoryLoadState) -> some View {
        switch state {
        case .idle, .loading:
            loadingView
        case .loaded(let sounds):
            if sounds.isEmpty { emptyView }
            else { soundsList(sounds: sounds) }
        case .failed(let message):
            errorView(message: message)
        }
    }

    // MARK: - Category Chips

    var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chipButton(label: "All", isSelected: selectedCategory == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                }
                ForEach(SleepSound.SoundCategory.allCases, id: \.self) { cat in
                    chipButton(label: cat.rawValue, isSelected: selectedCategory == cat) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = cat }
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
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? Color(red: 0.35, green: 0.25, blue: 0.75).opacity(0.7)
                              : Color.white.opacity(0.08))
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected
                                ? Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.5)
                                : Color.white.opacity(0.12),
                                lineWidth: 1
                            )
                        )
                )
        }
    }

    // MARK: - Sounds List

    func soundsList(sounds: [SleepSound]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(sounds) { sound in
                    SoundRowView(
                        sound: sound,
                        alarmSelectionMode: alarmSelectionMode,
                        onSelectForAlarm: {
                            player.selectForAlarm(sound)
                            onSoundSelected?(sound)
                        }
                    )
                }

                // Load More footer
                if currentState.isLoading {
                    ProgressView()
                        .tint(.white.opacity(0.5))
                        .padding(.vertical, 16)
                } else {
                    Button(action: { api.loadMore(for: selectedCategory) }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 14))
                            Text("Load more")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.vertical, 16)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - State Views

    var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().scaleEffect(1.4).tint(.white.opacity(0.6))
            Text("Loading sounds…")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.45))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 48)).foregroundColor(.white.opacity(0.2))
            Text("No sounds found")
                .font(.system(size: 17)).foregroundColor(.white.opacity(0.5))
            retryButton
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48)).foregroundColor(.white.opacity(0.25))
            Text("Failed to load")
                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            Text(message)
                .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            retryButton
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    var retryButton: some View {
        Button(action: { api.reload(for: selectedCategory) }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise").font(.system(size: 14, weight: .semibold))
                Text("Try Again").font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32).padding(.vertical, 13)
            .background(Color(red: 0.35, green: 0.25, blue: 0.75))
            .cornerRadius(22)
        }
    }

    // MARK: - Mini Player Bar

    var miniPlayerBar: some View {
        VStack(spacing: 0) {

            // Sound info + controls
            HStack(spacing: 12) {

                // Thumbnail with animation
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

                // Name + time
                VStack(alignment: .leading, spacing: 3) {
                    Text(player.currentSound?.name ?? "")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white).lineLimit(1)
                    Text(formatTime(player.currentTime) + " / " + formatTime(player.duration))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                // Volume -
                Button(action: { player.setVolume(max(0, player.volume - 0.2)) }) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 30, height: 30)
                }

                // Play / Pause
                Button(action: {
                    if player.isPlaying { player.pause() } else { player.resume() }
                }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }

                // Volume +
                Button(action: { player.setVolume(min(1, player.volume + 0.2)) }) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 30, height: 30)
                }

                // Close
                Button(action: { player.stop() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 4)

            // Single progress scrubber
            Slider(
                value: Binding(
                    get: { player.progress },
                    set: { player.seek(to: $0) }
                ),
                in: 0...1
            )
            .tint(Color(red: 0.5, green: 0.4, blue: 0.9))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(
            ZStack {
                Color(red: 0.10, green: 0.08, blue: 0.28).opacity(0.97)
                Rectangle().fill(.ultraThinMaterial).opacity(0.3)
            }
        )
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
        }
    }

    // MARK: - Time formatter

    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        let m = s / 60
        let r = s % 60
        return "\(m):\(String(format: "%02d", r))"
    }
}

// MARK: - Sound Row

struct SoundRowView: View {

    let sound: SleepSound
    var alarmSelectionMode: Bool = false
    var onSelectForAlarm: (() -> Void)? = nil

    @StateObject private var player = SleepSoundPlayer.shared

    private var isCurrentlyPlaying:   Bool { player.currentSound?.id == sound.id && player.isPlaying }
    private var isCurrentlyBuffering: Bool { player.currentSound?.id == sound.id && player.isBuffering }
    private var isSelectedForAlarm:   Bool { player.selectedAlarmSoundId == sound.id }

    var body: some View {
        HStack(spacing: 14) {
            soundThumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(sound.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white).lineLimit(1)
                Text(sound.category.rawValue)
                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.5))

                // مدة الصوت
                Text(formatDuration(sound.duration))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))

                if alarmSelectionMode && isSelectedForAlarm {
                    Text("Selected for alarm ✓")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.9, blue: 0.6))
                }
            }

            Spacer()

            HStack(spacing: 10) {
                if alarmSelectionMode {
                    Button(action: { onSelectForAlarm?() }) {
                        Image(systemName: isSelectedForAlarm ? "alarm.fill" : "alarm")
                            .font(.system(size: 16))
                            .foregroundColor(isSelectedForAlarm
                                             ? Color(red: 0.5, green: 0.9, blue: 0.6)
                                             : .white.opacity(0.4))
                    }
                }

                Button(action: { player.toggle(sound: sound) }) {
                    if isCurrentlyBuffering {
                        ProgressView().tint(.white).frame(width: 32, height: 32)
                    } else {
                        Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrentlyPlaying
                      ? Color(red: 0.2, green: 0.15, blue: 0.5).opacity(0.7)
                      : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isCurrentlyPlaying
                            ? Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.5)
                            : Color.white.opacity(0.07),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isCurrentlyPlaying)
    }

    func formatDuration(_ seconds: Double) -> String {
        guard seconds > 0 else { return "" }
        let s = Int(seconds)
        if s < 60 { return "\(s)s" }
        return "\(s / 60)m \(s % 60)s"
    }

    var soundThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(categoryGradient).frame(width: 60, height: 60)

            if let imgURL = sound.imageURL, let url = URL(string: imgURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    default: categoryIcon
                    }
                }
            } else {
                categoryIcon
            }

            if isCurrentlyPlaying {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.35)).frame(width: 60, height: 60)
                WaveformAnimationView().frame(width: 32, height: 24)
            }
        }
    }

    var categoryGradient: LinearGradient {
        switch sound.category {
        case .nature:
            return LinearGradient(colors: [Color(red:0.1,green:0.4,blue:0.45), Color(red:0.05,green:0.25,blue:0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .whiteNoise:
            return LinearGradient(colors: [Color(red:0.35,green:0.2,blue:0.55), Color(red:0.5,green:0.3,blue:0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .space:
            return LinearGradient(colors: [Color(red:0.1,green:0.1,blue:0.35), Color(red:0.2,green:0.15,blue:0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var categoryIcon: some View {
        Group {
            switch sound.category {
            case .nature:
                Image(systemName: "water.waves").font(.system(size: 22)).foregroundColor(.white.opacity(0.7))
            case .whiteNoise:
                Image(systemName: "waveform.path").font(.system(size: 22)).foregroundColor(.white.opacity(0.7))
            case .space:
                Image(systemName: "sparkles").font(.system(size: 22)).foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Waveform Animation

struct WaveformAnimationView: View {
    @State private var phase = false
    let bars = 4
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<bars, id: \.self) { i in
                Capsule().fill(Color.white)
                    .frame(width: 3, height: phase ? [18.0,10.0,22.0,12.0][i] : [8.0,20.0,6.0,18.0][i])
                    .animation(
                        .easeInOut(duration: 0.4 + Double(i)*0.1)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i)*0.08),
                        value: phase
                    )
            }
        }
        .onAppear { phase = true }
    }
}

// MARK: - Stars Background

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
    let id = UUID()
    let x, y, size: CGFloat
    let opacity: Double
}

#Preview {
    SleepSoundsView(selection: .constant(.sounds))
}

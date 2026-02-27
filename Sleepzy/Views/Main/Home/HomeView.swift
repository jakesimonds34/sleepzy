//
//  HomeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

/*
import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selection: Taps
    @State var isPlaying: Bool = false
    @State var isEnabled: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var currentlyPlaying: String? = "Ocean waves"
    private let sounds: [(name: String, category: String, image: String)] = [
        ("Ocean waves", "Nature", "wave.3.forward"),
        ("Ocean Drift", "Nature", "water.waves"),
        ("Brown Calm", "White Noise", "wind"),
        ("Pink Hush", "White Noise", "fanblades")
    ]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            content
        }
        .background(
            MyImage(source: .asset(.bgHome))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            headerView()
            sleepLastView()
            seeAllView()
            digitalShildView()
        }
        .padding(.bottom, 77)
        .padding(.horizontal, 16)
    }
    
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tuesday, February 3")
                .font(.appRegular14)
                .foregroundStyle(.white.opacity(0.6))
            
            Text("Good evening")
                .font(.appRegular(size: 34))
            
            Text("Sleep Mode")
                .font(.appMedium20)
                .padding(.top, 22)
            
            HStack(spacing: 5) {
                MyImage(source: .asset(.moonIcon, renderingMode: .template))
                    .scaledToFit()
                    .frame(width: 20)
                
                Text("Sleep Schedule")
                    .font(.appRegular16)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("10:00 PM")
                    .font(.appRegular(size: 18))
                
                Spacer()
            }
            .padding(.top, 16)
            
            Button {
                
            } label: {
                HStack {
                    MyImage(source: .asset(.windIcon))
                        .scaledToFit()
                        .frame(width: 24)
                    
                    Text("Start Wind-Down")
                        .font(.appRegular16)
                }
                .frame(height: 44)
                .padding(.horizontal, 15)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#322C94"),
                                 Color(hex: "#58359E"),
                                 Color(hex: "#58359E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(9)
            }
            .padding(.top, 20)
            .foregroundStyle(.white)

        }
    }
    
    private func sleepLastView() -> some View {
        HStack(spacing: 11) {
            MyImage(source: .asset(.sleepIcon, renderingMode: .template))
                .scaledToFit()
                .frame(width: 16)
            
            Spacer()
            
            Text("Sleep Last Night")
                .foregroundStyle(.white.opacity(0.2))
            
            Rectangle()
                .fill(.white)
                .frame(width: 1, height: 16)
            
            Circle()
                .fill(.clear)
                .stroke(Color(hex: "#08CE08"), lineWidth: 1)
                .frame(width: 14, height: 14)
            
            Text("7 Hr 15 min")
        }
        .font(.appRegular16)
        .frame(height: 43)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#1B113380").opacity(0.5),
                         Color(hex: "#58359E").opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(9)
    }
    
    @ViewBuilder
    private func seeAllView() -> some View {
        HStack {
            Text("Sleep Sounds")
                .font(.appRegular(size: 20))
            
            Spacer()
            
            Button {
                selection = .sounds
            } label: {
                Text("View All")
                    .underline()
                    .font(.appRegular(size: 13))
                    .foregroundStyle(.white)
            }
        }
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(sounds, id: \.name) { sound in
                soundRow(sound)
            }
        }
    }
    
    private func soundRow(_ sound: (name: String, category: String, image: String)) -> some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .overlay {
                    // MyImage(source: .asset(.bg))
                    //     .scaledToFill()
                }
            
            VStack {
                Button {
                    togglePlay(sound.name)
                } label: {
                    MyImage(source: .asset(currentlyPlaying == sound.name ? .pauseIcon : .playIcon))
                        .scaledToFit()
                        .frame(width: 50)
                }
                
                Text(sound.name)
            }
        }
        .frame(height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Play Logic
    private func togglePlay(_ name: String) {
        if currentlyPlaying == name {
            currentlyPlaying = nil
        } else {
            currentlyPlaying = name
        }
    }
    
    private func digitalShildView() -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#322C94"),
                                 Color(hex: "#58359E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay {
                    MyImage(source: .asset(.shieldIcon))
                        .scaledToFit()
                        .frame(width: 24)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Digital Shield")
                    .font(.appRegular(size: 20))
                
                Text("Active in 15 Min • 13 Apps Blocked")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.appRegular14)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6C5CE7")))
        }
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    HomeView(selection: $selection)
}
*/

/*
import SwiftUI

// MARK: - Home View (الشاشة الرئيسية)

struct HomeView: View {
    @State private var showNewBlock = false
    @State private var activeSession: SessionItem? = SessionItem.mockActive
    @State private var upcomingSessions: [SessionItem] = SessionItem.mockUpcoming
    @State private var sleepHours: Double = 7.25

    var body: some View {
        NavigationStack {
            ZStack {
                NightBackground().ignoresSafeArea()
                StarsView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // ── Header ──
                        HeaderView()
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 24)

                        // ── Active Session ──
                        if let session = activeSession {
                            SectionLabel(title: "الجلسة النشطة")
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)

                            ActiveSessionCard(session: session)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                        }

                        // ── Upcoming ──
                        SectionLabel(title: "الجلسات القادمة")
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        VStack(spacing: 8) {
                            ForEach(upcomingSessions) { session in
                                UpcomingSessionRow(session: session)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 16)

                        // ── Add Button ──
                        AddSessionButton {
                            showNewBlock = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                        // ── Sleep Bar ──
                        SleepBar(hours: sleepHours)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewBlock = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .sheet(isPresented: $showNewBlock) {
                NavigationStack {
                    NewBlockView()
                }
                .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Header

struct HeaderView: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "صباح الخير"
        case 12..<17: return "مساء النور"
        case 17..<21: return "مساء الخير"
        default:      return "مساء الخير"
        }
    }

    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "☀️"
        case 12..<17: return "🌤"
        case 17..<21: return "🌅"
        default:      return "🌙"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "EEEE، d MMMM"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateString.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
                .kerning(1.5)
            HStack(alignment: .center, spacing: 8) {
                Text(greeting)
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
                Text(greetingEmoji)
                    .font(.system(size: 26))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white.opacity(0.3))
            .kerning(1.8)
            .textCase(.uppercase)
    }
}

// MARK: - Session Models

struct SessionItem: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var startTime: String
    var endTime: String
    var isActive: Bool
    var isEnabled: Bool
    var blockedAppsEmojis: [String]
    var blockedAppsCount: Int
    var progressFraction: Double

    static let mockActive = SessionItem(
        name: "وضع النوم",
        emoji: "🌙",
        startTime: "10:30 م",
        endTime: "7:30 ص",
        isActive: true,
        isEnabled: true,
        blockedAppsEmojis: ["𝕏", "📷", "🎵", "👻", "▶️"],
        blockedAppsCount: 9,
        progressFraction: 0.62
    )

    static let mockUpcoming: [SessionItem] = [
        SessionItem(
            name: "وضع العمل",
            emoji: "💼",
            startTime: "9:00 ص",
            endTime: "1:00 م",
            isActive: false,
            isEnabled: true,
            blockedAppsEmojis: [],
            blockedAppsCount: 5,
            progressFraction: 0
        ),
        SessionItem(
            name: "وضع الدراسة",
            emoji: "📚",
            startTime: "4:00 م",
            endTime: "7:00 م",
            isActive: false,
            isEnabled: true,
            blockedAppsEmojis: [],
            blockedAppsCount: 7,
            progressFraction: 0
        )
    ]
}

// MARK: - Active Session Card

struct ActiveSessionCard: View {
    let session: SessionItem
    @State private var animateProgress = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top row
            HStack(spacing: 12) {
                // Shield icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.42, green: 0.28, blue: 0.94),
                                         Color(red: 0.60, green: 0.25, blue: 0.91)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, y: 5)

                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(session.emoji)
                        Text(session.name)
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.white)
                    }
                    HStack(spacing: 6) {
                        // Live badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 5, height: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.green.opacity(0.3), lineWidth: 3)
                                        .scaleEffect(1.5)
                                )
                            Text("نشط الآن")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.green.opacity(0.25), lineWidth: 1))

                        Text("ينتهي \(session.endTime)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                // Toggle (on)
                ActiveToggle(isOn: true)
            }

            // Progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("مدة الجلسة")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))
                    Spacer()
                    Text("٥ س ٣٠ د / ٩ ساعات")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 1.0))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.42, green: 0.28, blue: 0.94),
                                             Color(red: 0.75, green: 0.25, blue: 0.95)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: animateProgress ? geo.size.width * session.progressFraction : 0, height: 5)
                            .animation(.easeOut(duration: 1.0).delay(0.3), value: animateProgress)
                    }
                }
                .frame(height: 5)
            }

            Divider()
                .background(Color.white.opacity(0.07))

            // Blocked apps
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("التطبيقات المحجوبة")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))

                    HStack(spacing: 6) {
                        ForEach(session.blockedAppsEmojis.prefix(4), id: \.self) { emoji in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                Text(emoji)
                                    .font(.system(size: 16))
                            }
                            .frame(width: 32, height: 32)
                        }

                        if session.blockedAppsCount > 4 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.purple.opacity(0.25), lineWidth: 1)
                                    )
                                Text("+\(session.blockedAppsCount - 4)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 1.0))
                            }
                            .frame(width: 32, height: 32)
                        }
                    }
                }

                Spacer()

                Button {} label: {
                    Text("إدارة")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 1.0))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.purple.opacity(0.2), lineWidth: 1))
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.27, blue: 0.78).opacity(0.22),
                                Color(red: 0.20, green: 0.18, blue: 0.60).opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(red: 0.55, green: 0.45, blue: 1.0).opacity(0.22), lineWidth: 1)
            }
        )
        .onAppear { animateProgress = true }
    }
}

// MARK: - Active Toggle

struct ActiveToggle: View {
    let isOn: Bool
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color.green : Color.white.opacity(0.15))
                .frame(width: 44, height: 26)
                .shadow(color: isOn ? Color.green.opacity(0.3) : .clear, radius: 6)
            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
                .padding(.horizontal, 2)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isOn)
    }
}

// MARK: - Upcoming Session Row

struct UpcomingSessionRow: View {
    @State var session: SessionItem

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .stroke(Color.white.opacity(0.09), lineWidth: 1)
                    )
                Text(session.emoji)
                    .font(.system(size: 20))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(session.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                HStack(spacing: 3) {
                    Text("يبدأ")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                    Text(session.startTime)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
                    Text("—")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.2))
                    Text(session.endTime)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Spacer()

            // Toggle (off for upcoming)
            ActiveToggle(isOn: session.isEnabled)
                .onTapGesture {
                    session.isEnabled.toggle()
                }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

// MARK: - Add Session Button

struct AddSessionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 26, height: 26)
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
                Text("إضافة جلسة جديدة")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(.white.opacity(0.12))
            )
        }
    }
}

// MARK: - Sleep Bar

struct SleepBar: View {
    let hours: Double

    private var hoursText: String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h) س \(m) د"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))

            Text("النوم الليلة الماضية")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.35))

            Spacer()

            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 14)

            HStack(spacing: 5) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                Text(hoursText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stars Decoration

struct StarsView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<50, id: \.self) { i in
                let seed = Double(i * 7 + 13)
                let x = (seed * 137.5).truncatingRemainder(dividingBy: 100) / 100
                let y = (seed * 97.3).truncatingRemainder(dividingBy: 100) / 100
                let size = (seed * 0.07).truncatingRemainder(dividingBy: 1.5) + 0.5
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: size, height: size)
                    .position(
                        x: x * geo.size.width,
                        y: y * geo.size.height * 0.55
                    )
            }
        }
        .allowsHitTesting(false)
    }
}
*/

/*

// DigitalShield — HomeView.swift
import SwiftUI
import FamilyControls

// ─────────────────────────────────────────────────────────────────────────────
// MARK: HomeView
// ─────────────────────────────────────────────────────────────────────────────

struct HomeView: View {
    @StateObject private var store = SessionStore()
    @State private var showNew    = false
    @State private var detailID   : UUID?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DSNightBG()
                DSStars().ignoresSafeArea()
                MoonDecor()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        HomeHeader()
                            .padding(.horizontal, 22)
                            .padding(.top, 60)
                            .padding(.bottom, 26)

                        // ── Active / Idle ─────────────────────────────────────
                        if let active = store.active {
                            DSEyebrow(text: "الجلسة النشطة")
                                .padding(.horizontal, 22).padding(.bottom, 10)
                            ActiveCard(session: active, store: store)
                                .padding(.horizontal, 16)
                        } else {
                            IdleCard()
                                .padding(.horizontal, 16)
                        }
                        Spacer().frame(height: 26)

                        // ── Upcoming ──────────────────────────────────────────
                        HStack {
                            DSEyebrow(text: "الجلسات القادمة")
                            Spacer()
                            Text("\(store.upcoming.count) جلسات")
                                .font(.dsCaption(10)).foregroundStyle(Color.dsTextTert)
                        }
                        .padding(.horizontal, 22).padding(.bottom, 10)

                        VStack(spacing: 8) {
                            ForEach(store.upcoming) { s in
                                UpcomingRow(sessionID: s.id, store: store)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                    .onTapGesture { detailID = s.id }
                            }
                        }
                        .padding(.bottom, 16)

                        AddTile { showNew = true }
                            .padding(.horizontal, 16).padding(.bottom, 20)

                        SleepBar()
                            .padding(.horizontal, 16).padding(.bottom, 52)
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .sheet(isPresented: $showNew) {
                NewBlockView(store: store).preferredColorScheme(.dark)
            }
            // Sheet binds to a live session from store — always fresh
            .sheet(item: Binding(
                get: { detailID.flatMap { id in store.sessions.first { $0.id == id } } },
                set: { detailID = $0?.id }
            )) { session in
                SessionDetailView(sessionID: session.id, store: store)
                    .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
        .task { await store.requestAuth() }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Decorations
// ─────────────────────────────────────────────────────────────────────────────

private struct MoonDecor: View {
    var body: some View {
        GeometryReader { g in
            Circle()
                .fill(RadialGradient(
                    colors: [Color(red: 0.97, green: 0.94, blue: 0.87),
                             Color(red: 0.80, green: 0.76, blue: 0.62)],
                    center: .init(x: 0.35, y: 0.35),
                    startRadius: 0, endRadius: 46))
                .frame(width: 76, height: 76)
                .shadow(color: Color(red: 0.88, green: 0.82, blue: 0.60).opacity(0.30), radius: 28)
                .shadow(color: Color(red: 0.88, green: 0.82, blue: 0.60).opacity(0.08), radius: 65)
                .position(x: g.size.width - 52, y: 83)
        }
        .allowsHitTesting(false)
    }
}

private struct HomeHeader: View {
    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "صباح الخير"
        case 12..<18: return "مساء النور"
        default:      return "مساء الخير"
        }
    }
    private var dateStr: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar")
        f.dateFormat = "EEEE، d MMMM"
        return f.string(from: Date())
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateStr.uppercased())
                .font(.dsCaption(11)).foregroundStyle(Color.dsTextTert).kerning(1.8)
            Text(greeting + "  🌙")
                .font(.dsDisplay(28)).foregroundStyle(Color.dsText)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Active Card
// No fake icons — if blockedCount == 0: show empty state
// If blockedCount > 0: show real Label(token) icons from FamilyControls
// ─────────────────────────────────────────────────────────────────────────────

private struct ActiveCard: View {
    let session: DSSession
    @ObservedObject var store: SessionStore
    @State private var barIn  = false
    @State private var ringIn = false

    var body: some View {
        VStack(spacing: 0) {

            // Header row
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.dsPurple.opacity(0.18), lineWidth: 1.5)
                        .frame(width: 58, height: 58)
                        .scaleEffect(ringIn ? 1.32 : 1.0)
                        .opacity(ringIn ? 0 : 0.60)
                        .animation(.easeOut(duration: 2.0).repeatForever(autoreverses: false), value: ringIn)
                    DSIconBox(icon: "checkmark.shield.fill", size: 50, iconSize: 21)
                }
                .onAppear { ringIn = true }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(session.emoji).font(.system(size: 18))
                        Text(session.name).font(.dsTitle(17)).foregroundStyle(Color.dsText)
                    }
                    HStack(spacing: 8) {
                        DSBadge(text: "نشط الآن", color: .dsGreen, dot: true)
                        Text("ينتهي \(session.endLabel)")
                            .font(.dsCaption(10)).foregroundStyle(Color.dsTextTert)
                    }
                }
                Spacer()

                // Active toggle (always ON while session is active)
                ZStack(alignment: .trailing) {
                    Capsule().fill(Color.dsGreen).frame(width: 48, height: 27)
                        .shadow(color: Color.dsGreen.opacity(0.26), radius: 7)
                    Circle().fill(Color.white).frame(width: 23, height: 23).padding(.trailing, 2)
                }
            }
            .padding(18).padding(.bottom, 10)

            // Progress bar
            VStack(spacing: 7) {
                HStack {
                    Text("وقت الجلسة")
                        .font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
                    Spacer()
                    Text(progressText)
                        .font(.dsCaption(11)).foregroundStyle(Color.dsViolet).fontWeight(.semibold)
                }
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.07))
                        Capsule().fill(LinearGradient.dsBrand)
                            .frame(width: barIn ? g.size.width * session.progress : 0)
                            .animation(.easeOut(duration: 1.1).delay(0.2), value: barIn)
                    }.frame(height: 5)
                }.frame(height: 5)
            }
            .padding(.horizontal, 18).padding(.bottom, 14)

            Divider().background(Color.dsBorder).padding(.horizontal, 18)

            // Apps row + manage button
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("التطبيقات المحجوبة")
                        .font(.dsCaption(10.5)).foregroundStyle(Color.dsTextTert)

                    if session.blockedCount == 0 {
                        // No selection yet — clear honest empty state
                        HStack(spacing: 6) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 13)).foregroundStyle(Color.dsTextTert)
                            Text("لم يتم الاختيار بعد")
                                .font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
                        }
                    } else {
                        // Real token icons — OS resolves the actual app icon
                        HStack(spacing: 6) {
                            ForEach(Array(session.selection.applicationTokens.prefix(5)), id: \.self) { token in
                                Label(token)
                                    .labelStyle(.iconOnly)
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.07))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.dsBorder, lineWidth: 1))
                            }
                            if session.blockedCount > 5 {
                                Text("+\(session.blockedCount - 5)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.dsViolet)
                                    .frame(width: 32, height: 32)
                                    .background(Color.dsPurple.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.dsPurple.opacity(0.22), lineWidth: 1))
                            }
                        }
                    }
                }
                Spacer()
                NavigationLink {
                    AppManagementView(sessionID: session.id, store: store)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "hourglass").font(.system(size: 11, weight: .semibold))
                        Text("إدارة").font(.dsLabel(12))
                    }
                    .foregroundStyle(Color.dsViolet)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Color.dsPurple.opacity(0.11))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.dsPurple.opacity(0.20), lineWidth: 1))
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.30, green: 0.22, blue: 0.70).opacity(0.24),
                        Color(red: 0.15, green: 0.13, blue: 0.50).opacity(0.12)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.dsPurple.opacity(0.24), lineWidth: 1))
        )
        .onAppear { barIn = true }
    }

    private var progressText: String {
        let total = 9.0; let done = total * session.progress
        return "\(Int(done)) س من \(Int(total)) ساعات"
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Idle Card
// ─────────────────────────────────────────────────────────────────────────────

private struct IdleCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.dsSurface).frame(width: 46, height: 46)
                Image(systemName: "shield.slash")
                    .font(.system(size: 18)).foregroundStyle(Color.dsTextTert)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("لا توجد جلسة نشطة")
                    .font(.dsBody(14)).foregroundStyle(Color.dsTextSec)
                Text("الجلسة القادمة تبدأ بعد ٤ ساعات")
                    .font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
            }
            Spacer()
        }
        .surfaceCard(pad: 14)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Upcoming Row
// Reads from store by ID — toggle writes directly to store
// ─────────────────────────────────────────────────────────────────────────────

struct UpcomingRow: View {
    let sessionID: UUID
    @ObservedObject var store: SessionStore

    private var session: DSSession? {
        store.sessions.first { $0.id == sessionID }
    }

    var body: some View {
        if let s = session {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.dsSurface)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.dsBorder, lineWidth: 1))
                    Text(s.emoji).font(.system(size: 20))
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(s.name).font(.dsBody(15)).foregroundStyle(Color.dsText)
                    HStack(spacing: 3) {
                        Text("يبدأ").font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
                        Text(s.startLabel)
                            .font(.dsCaption(11)).foregroundStyle(Color.dsAmber)
                            .fontWeight(.semibold)
                        Text("—").font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
                        Text(s.endLabel).font(.dsCaption(11)).foregroundStyle(Color.dsTextTert)
                    }
                }
                Spacer()

                if s.blockedCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "lock.fill").font(.system(size: 8))
                        Text("\(s.blockedCount)").font(.dsCaption(10))
                    }
                    .foregroundStyle(Color.dsTextTert)
                    .padding(.horizontal, 7).padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Capsule())
                }

                // Toggle bound directly to store — no local @State copy
                Toggle("", isOn: Binding(
                    get: { s.isEnabled },
                    set: { _ in store.toggleEnabled(s.id) }
                ))
                .labelsHidden()
                .tint(Color.dsPurple)
                .scaleEffect(0.85)
            }
            .padding(13)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.dsSurface)
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.dsBorder, lineWidth: 1))
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Add Tile + Sleep Bar
// ─────────────────────────────────────────────────────────────────────────────

private struct AddTile: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                ZStack {
                    Circle().fill(Color.dsPurple.opacity(0.12)).frame(width: 28, height: 28)
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsPurple)
                }
                Text("إضافة جلسة جديدة")
                    .font(.dsLabel(13)).foregroundStyle(Color.dsTextTert)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 15)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [7, 4]))
                    .foregroundStyle(Color.white.opacity(0.09))
            )
        }
    }
}

private struct SleepBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 13)).foregroundStyle(Color.dsTextTert)
            Text("النوم الليلة الماضية")
                .font(.dsCaption(12)).foregroundStyle(Color.dsTextTert)
            Spacer()
            Rectangle().fill(Color.dsBorder).frame(width: 1, height: 14)
            HStack(spacing: 5) {
                Circle().fill(Color.dsGreen).frame(width: 6, height: 6)
                Text("٧ س ١٥ د").font(.dsLabel(13)).foregroundStyle(Color.dsText)
            }
        }
        .surfaceCard(radius: 16, pad: 14)
    }
}
 
*/

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            MyImage(source: .asset(.bgHome))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        Text("Home")
    }
}

#Preview {
    HomeView()
}

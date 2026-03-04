//
//  SleepLogView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

// MARK: - SleepLogView

struct SleepLogView: View {

    @StateObject private var hk = HealthKitManager.shared
    @State private var period: SleepPeriod = .weekly
    @State private var offset = 0
    @State private var selectedSession: SleepSession? = nil
    
    @Binding var selection: Taps

    // MARK: - Computed

    private var currentRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .weekly:
            let weekStart = cal.date(
                from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            )!
            let start = cal.date(byAdding: .weekOfYear, value: offset, to: weekStart)!
            let end   = cal.date(byAdding: .day, value: 7, to: start)!
            return (start, end)
        case .monthly:
            let monthStart = cal.date(
                from: cal.dateComponents([.year, .month], from: now)
            )!
            let start = cal.date(byAdding: .month, value: offset, to: monthStart)!
            let end   = cal.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .yearly:
            let yearStart = cal.date(
                from: cal.dateComponents([.year], from: now)
            )!
            let start = cal.date(byAdding: .year, value: offset, to: yearStart)!
            let end   = cal.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        }
    }

    private var displayedSessions: [SleepSession] {
        let (start, end) = currentRange
        return hk.sessions.filter { $0.date >= start && $0.date < end }
    }

    private var periodLabel: String {
        let f = DateFormatter()
        let (start, end) = currentRange
        switch period {
        case .weekly:
            f.dateFormat = "d MMM"
            let endDay = Calendar.current.date(byAdding: .day, value: -1, to: end)!
            return "\(f.string(from: start)) - \(f.string(from: endDay))"
        case .monthly:
            f.dateFormat = "MMMM yyyy"
            return f.string(from: start)
        case .yearly:
            f.dateFormat = "yyyy"
            return f.string(from: start)
        }
    }

    private var avgHours: Double {
        guard !displayedSessions.isEmpty else { return 0 }
        return displayedSessions.map(\.totalHours).reduce(0,+) / Double(displayedSessions.count)
    }
    private var avgQuality: Int {
        guard !displayedSessions.isEmpty else { return 0 }
        return displayedSessions.map(\.qualityPercent).reduce(0,+) / displayedSessions.count
    }
    private var avgDurationString: String {
        let h = Int(avgHours); let m = Int((avgHours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                AppHeaderView(title: "Sleep log", subTitle: "", paddingTop: 0)
                    .padding(.horizontal)

                periodPicker
                periodNavigator
                avgStatsCard

                if displayedSessions.isEmpty {
                    emptyState
                } else {
                    ForEach(displayedSessions) { session in
                        sessionCard(session)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            .padding(.bottom, 40)
        }
        .background(
            MyImage(source: .asset(.bgSounds))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .sheet(item: $selectedSession) { session in
            SleepAnalyticsView(session: session)
        }
        .task {
            if !hk.isAuthorized { await hk.requestAuthorization() }
            else { await hk.fetchSleepData(for: period) }
        }
        .onChange(of: period) { _, p in
            offset = 0
            Task { await hk.fetchSleepData(for: p) }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(SleepPeriod.allCases, id: \.self) { p in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { period = p }
                } label: {
                    Text(p.rawValue)
                        .font(.appMedium14)
                        .foregroundColor(period == p ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(period == p ? Color(hex: "5939A8") : Color.clear)
                        .clipShape(.rect)
                        .cornerRadius(6)
                }
            }
        }
        .padding(4)
        .clipShape(.rect)
        .cornerRadius(8)
    }

    // MARK: - Period Navigator

    private var periodNavigator: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { offset -= 1 }
            } label: {
                MyImage(source: .system("chevron.left"))
                    .frame(width: 8)
                    .foregroundColor(.white)
            }

            Spacer()

            Text(periodLabel)
                .foregroundColor(.white)
                .font(.appMedium20)
                .animation(.none, value: periodLabel)

            Spacer()

            Button {
                if offset < 0 {
                    withAnimation(.easeInOut(duration: 0.15)) { offset += 1 }
                }
            } label: {
                MyImage(source: .system("chevron.right"))
                    .frame(width: 8)
                    .foregroundColor(offset < 0 ? .white : .white.opacity(0.3))
            }
        }
    }

    // MARK: - Avg Stats Card

    private var avgStatsCard: some View {
        HStack(spacing: 20) {
            statCard(
                icon: .sleepIcon,
                title: "Avg Sleep:",
                value: avgDurationString,
                change: "+5%"
            )
            statCard(
                icon: .percentIcon,
                title: "Sleep Quality",
                value: displayedSessions.isEmpty ? "--" : "\(avgQuality)%",
                change: "+5%"
            )
        }
    }

    private func statCard(icon: ImageResource, title: String, value: String, change: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 16) {
                MyImage(source: .asset(icon))
                    .scaledToFit()
                    .frame(width: 32)

                Text(title)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.appRegular16)
            }

            HStack {
                Text(value)
                    .foregroundColor(.white)
                    .font(.appBold24)

                HStack(spacing: 0) {
                    Text(change)
                        .font(.appRegular14)
                    Image(systemName: "arrow.up")
                        .font(.appBold10)
                }
                .foregroundColor(Color(hex: "17B26A"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.accent, AppTheme.accent.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Session Card

    private func sessionCard(_ s: SleepSession) -> some View {
        Button {
            selectedSession = s
        } label: {
            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(s.displayBedtime) - \(s.displayWakeTime)")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.appRegular(size: 18))
                    }
                    Spacer()
                    Text(s.displayDate)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.appRegular16)
                }

                HStack {
                    Text(s.displayDuration)
                        .font(.appMedium24)
                        .foregroundColor(.white)

                    Spacer()

                    // ✅ border فقط (stroke) مع لون الحالة الصحيح
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(qualityColor(s.qualityLabel), lineWidth: 1.5)
                            .frame(width: 13, height: 13)
                        Text(s.qualityLabel)
                            .font(.appRegular16)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.4))
            Text("No sleep data for this period")
                .font(.appRegular16)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: - Helpers

    // نفس ألوان SleepAnalyticsView
    private func qualityColor(_ label: String) -> Color {
        switch label {
        case "Good": return Color(hex: "17B26A")   // أخضر — Normal
        case "Fair": return Color(hex: "F79009")   // برتقالي — Low
        default:     return Color(hex: "F04438")   // أحمر — High/Poor
        }
    }
}

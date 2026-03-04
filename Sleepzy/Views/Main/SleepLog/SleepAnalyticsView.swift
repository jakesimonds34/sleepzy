import SwiftUI

// MARK: - SleepAnalyticsView (Right screen — Image 2)

struct SleepAnalyticsView: View {

    let session: SleepSession
    @Environment(\.dismiss) private var dismiss

    // Stage summaries for bottom section
    private var summaries: [StageSummary] {
        let total = Double(session.awakeMinutes + session.remMinutes +
                           session.lightMinutes + session.deepMinutes)
        guard total > 0 else { return [] }

        func pct(_ m: Int) -> Int { Int(Double(m) / total * 100) }

        return [
            StageSummary(stage: .awake,
                         minutes: session.awakeMinutes,
                         percent: pct(session.awakeMinutes),
                         level: awakeLevel(pct(session.awakeMinutes)),
                         levelColor: awakeLevelColor(pct(session.awakeMinutes))),

            StageSummary(stage: .rem,
                         minutes: session.remMinutes,
                         percent: pct(session.remMinutes),
                         level: remLevel(pct(session.remMinutes)),
                         levelColor: remLevelColor(pct(session.remMinutes))),

            StageSummary(stage: .lightSleep,
                         minutes: session.lightMinutes,
                         percent: pct(session.lightMinutes),
                         level: lightLevel(pct(session.lightMinutes)),
                         levelColor: lightLevelColor(pct(session.lightMinutes))),

            StageSummary(stage: .deepSleep,
                         minutes: session.deepMinutes,
                         percent: pct(session.deepMinutes),
                         level: deepLevel(pct(session.deepMinutes)),
                         levelColor: deepLevelColor(pct(session.deepMinutes))),
        ]
    }

    // MARK: - Level Calculators (based on sleep science benchmarks)
    //
    // Awake:      Normal 5–10% | Low <5% | High >10%
    // REM:        Normal 20–25% | Low <15% | High >30%
    // Light Sleep:Normal 45–55% | Low <40% | High >60%
    // Deep Sleep: Normal 15–20% | Low <10% | High >25%

    private func awakeLevel(_ pct: Int) -> String {
        switch pct {
        case ..<5:    return "Low"
        case 5...10:  return "Normal"
        default:      return "High"
        }
    }
    private func awakeLevelColor(_ pct: Int) -> String {
        switch pct {
        case ..<5:    return "17B26A"   // green — low awake is fine
        case 5...10:  return "17B26A"   // green — normal
        default:      return "F04438"   // red   — high awake = poor sleep
        }
    }

    private func remLevel(_ pct: Int) -> String {
        switch pct {
        case ..<15:   return "Low"
        case 15...30: return "Normal"
        default:      return "High"
        }
    }
    private func remLevelColor(_ pct: Int) -> String {
        switch pct {
        case ..<15:   return "F79009"   // orange — low REM
        case 15...30: return "17B26A"
        default:      return "F04438"   // red    — high REM
        }
    }

    private func lightLevel(_ pct: Int) -> String {
        switch pct {
        case ..<40:   return "Low"
        case 40...60: return "Normal"
        default:      return "High"
        }
    }
    private func lightLevelColor(_ pct: Int) -> String {
        switch pct {
        case ..<40:   return "F79009"
        case 40...60: return "17B26A"
        default:      return "F04438"
        }
    }

    private func deepLevel(_ pct: Int) -> String {
        switch pct {
        case ..<10:   return "Low"
        case 10...25: return "Normal"
        default:      return "High"
        }
    }
    private func deepLevelColor(_ pct: Int) -> String {
        switch pct {
        case ..<10:   return "F04438"   // red  — low deep sleep
        case 10...25: return "17B26A"
        default:      return "F04438"   // red   — unusually high deep sleep
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.nightSkyGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Header stats
                        headerStats

                        // Sleep stage chart
                        stageChart
                            .padding(.horizontal, AppTheme.pagePadding)

                        // Legend
                        legendRow
                            .padding(.horizontal, AppTheme.pagePadding)

                        // Stage detail cards
                        ForEach(summaries, id: \.stage) { s in
                            stageCard(s)
                                .padding(.horizontal, AppTheme.pagePadding)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top) {
                topBar
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(formattedDate)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("\(session.displayBedtime) - \(session.displayWakeTime)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // Invisible placeholder to center the title
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 52)
        .padding(.bottom, 12)
        .background(AppTheme.background.opacity(0.01))
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMMM"
        return f.string(from: session.date)
    }

    // MARK: - Header Stats

    private var headerStats: some View {
        HStack(spacing: 12) {

            // Card 1 — Sleep Time
            VStack(alignment: .leading, spacing: 6) {
                Image(.sleepIcon)
                    .resizable()
                    .frame(width: 32, height: 32)

                Text("Sleep Time")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(session.displayDuration)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    trendBadge("+5%")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.cardPadding)
            .background(
                LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))

            // Card 2 — Sleep Quality
            VStack(alignment: .leading, spacing: 6) {
                Image(.percentIcon)
                    .resizable()
                    .frame(width: 32, height: 32)

                Text("Sleep Quality")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(session.qualityPercent)%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    trendBadge("+5%")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.cardPadding)
            .background(
                LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        }
        .padding(.horizontal, AppTheme.pagePadding)
    }

    private func trendBadge(_ t: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "arrow.up").font(.system(size: 9, weight: .bold))
            Text(t).font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(Color(hex: "4CD964"))
    }

    // MARK: - Sleep Stage Chart (replaced by SleepStageChart component)

    private var stageChart: some View {
        SleepStageChart(session: session)
    }

    // MARK: - Legend

    private var legendRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(SleepStage.allCases, id: \.self) { stage in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(hex: stage.color))
                            .frame(width: 8, height: 8)
                        Text(stage.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Stage Card

    private func stageCard(_ s: StageSummary) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(s.stage.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(formatMinutes(s.minutes))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("(\(s.percent)% of sleep)")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Level badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: s.levelColor))
                        .frame(width: 7, height: 7)
                    Text(s.level)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: s.levelColor))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: s.levelColor).opacity(0.2))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(hex: s.levelColor), lineWidth: 1))
            }

            Spacer()

            // Vertical bar indicator
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 8, height: 60)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: s.stage.color).opacity(0.5), Color(hex: s.stage.color)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: max(8, CGFloat(s.percent) / 100 * 60))
            }
        }
        .padding(AppTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.05), .white.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
    }

    // MARK: - Helpers

    private func formatMinutes(_ m: Int) -> String {
        let h = m / 60; let rem = m % 60
        if h > 0 { return "\(h) h \(rem) m" }
        return "\(rem) m"
    }
}

import SwiftUI

// MARK: - SleepStageChart
// مطابق للتصميم:
// • 4 صفوف أفقية (Awake أعلى، Deep أسفل)
// • خطوط فاصلة أفقية بين الصفوف
// • أعمدة عمودية ملونة على timeline
// • بدون corner radius على الـ chart
// • المحور X = ساعات النوم (0 → 8 كحد أدنى)

struct SleepStageChart: View {

    let session: SleepSession

    private let stageOrder: [SleepStage] = [.awake, .rem, .lightSleep, .deepSleep]
    private let chartHeight: CGFloat = 160
    private let rowCount: CGFloat = 4

    // محور X: دائماً 8 ساعات كحد أدنى
    private var axisMax: Int {
        max(8, Int(ceil(session.totalHours)))
    }

    var body: some View {
        VStack(spacing: 6) {
            chartArea
            xAxisLabels
        }
    }

    // MARK: - Chart Area

    private var chartArea: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let rowH = chartHeight / rowCount

            ZStack(alignment: .topLeading) {

                // ── خلفية داكنة ──────────────────────────────
                AppTheme.cardBackground

                // ── خطوط أفقية فاصلة بين الصفوف ─────────────
                // مثل التصميم: خطوط أفقية وليس عمودية
                ForEach(1..<4) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: w, height: 1)
                        .offset(x: 0, y: CGFloat(i) * rowH)
                }

                // ── أعمدة كل segment ──────────────────────────
                ForEach(session.segments) { seg in
                    let rowIdx = stageOrder.firstIndex(of: seg.stage) ?? 0

                    let x    = CGFloat(seg.startHour   / Double(axisMax)) * w
                    let barW = max(2, CGFloat(seg.durationHours / Double(axisMax)) * w)
                    let barH = rowH * 0.72
                    let y    = CGFloat(rowIdx) * rowH + (rowH - barH) / 2

                    Rectangle()   // بدون corner radius مثل التصميم
                        .fill(Color(hex: seg.stage.color))
                        .frame(width: barW, height: barH)
                        .offset(x: x, y: y)
                }
            }
            .frame(width: w, height: chartHeight)
            // بدون clipShape → بدون corner radius
        }
        .frame(height: chartHeight)
    }

    // MARK: - X Axis Labels

    private var xAxisLabels: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ForEach(0...axisMax, id: \.self) { hour in
                let x = CGFloat(hour) / CGFloat(axisMax) * w
                Text("\(hour)")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 16, alignment: .center)
                    .offset(x: x - 8, y: 0)
            }
        }
        .frame(height: 14)
    }
}

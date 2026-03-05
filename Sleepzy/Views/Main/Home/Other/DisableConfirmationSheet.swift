import SwiftUI

// MARK: - DisableConfirmationSheet
// يظهر عند محاولة تعطيل block أو timer
// - عداد 15 ثانية
// - زر "Continue" معطّل حتى انتهاء العداد

struct DisableConfirmationSheet: View {
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var secondsLeft: Int = 15
    @State private var timer: Timer? = nil
    @State private var progress: Double = 1.0

    var body: some View {
        ZStack {
            // خلفية داكنة
            Color(hex: "0A0E2A").ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // ── Warning Icon ──────────────────────────────
                ZStack {
                    Circle()
                        .fill(Color(hex: "F04438").opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: "F04438"))
                }

                // ── Title ─────────────────────────────────────
                VStack(spacing: 10) {
                    Text("Are You Sure?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Disabling this block removes\nyour protection.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // ── Countdown Ring ────────────────────────────
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(hex: "5939A8"),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                        .animation(.linear(duration: 1), value: progress)

                    Text("\(secondsLeft)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                // ── Buttons ───────────────────────────────────
                VStack(spacing: 12) {
                    // Continue — معطّل حتى انتهاء العداد
                    Button {
                        timer?.invalidate()
                        dismiss()
                        onConfirm()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(secondsLeft == 0 ? Color(hex: "0A0E2A") : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                secondsLeft == 0
                                    ? Color.white
                                    : Color.white.opacity(0.08)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        secondsLeft == 0 ? Color.clear : Color.white.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .disabled(secondsLeft > 0)

                    // Cancel
                    Button {
                        timer?.invalidate()
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Timer

    private func startTimer() {
        secondsLeft = 15
        progress = 1.0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
                progress = Double(secondsLeft) / 15.0
            } else {
                timer?.invalidate()
            }
        }
    }
}

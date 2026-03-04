import SwiftUI

// MARK: - AlarmRingingView
// تظهر تلقائياً فوق كل شيء عندما يرنّ المنبه والتطبيق مفتوح

struct AlarmRingingView: View {

    let alarm: Alarm
    @StateObject private var manager = AlarmManager.shared

    // Animations
    @State private var pulse      = false
    @State private var bellShake  = false
    @State private var appeared   = false

    // Elapsed timer — كم ثانية مضت منذ رنين المنبه
    @State private var elapsed: Int = 0
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            // ── Background ──
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.15),
                    Color(red: 0.09, green: 0.05, blue: 0.28),
                    Color(red: 0.05, green: 0.03, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarsBackgroundView().ignoresSafeArea()

            // ── Pulse rings behind bell ──
            pulseRings

            VStack(spacing: 0) {

                Spacer()

                // ── Bell icon ──
                ZStack {
                    // Glow
                    Circle()
                        .fill(Color(hex: "#5939A8").opacity(0.35))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#7A5CE8"), Color(hex: "#3B2A8E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "#6B4FD8").opacity(0.7), radius: 24)

                    Image(systemName: "alarm.fill")
                        .font(.system(size: 54, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(
                            .degrees(bellShake ? 14 : -14),
                            anchor: .top
                        )
                }
                .scaleEffect(appeared ? 1.0 : 0.4)
                .opacity(appeared ? 1.0 : 0.0)

                Spacer().frame(height: 36)

                // ── "ALARM" label ──
                Text("ALARM")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .tracking(4)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 10)

                // ── Time ──
                Text(alarm.timeString)
                    .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)

                Spacer().frame(height: 6)

                // ── Repeat label ──
                Text(alarm.repeatLabel)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.45))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 8)

                // ── Ringtone name ──
                HStack(spacing: 5) {
                    Image(systemName: "music.note")
                        .font(.system(size: 12))
                    Text(alarm.ringtone)
                        .font(.system(size: 13))
                }
                .foregroundColor(.white.opacity(0.3))
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 24)

                // ── Elapsed time ──
                Text(elapsedLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
                    .opacity(appeared ? 1 : 0)

                Spacer()

                // ── Buttons ──
                buttonsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 44)

                Spacer().frame(height: 52)
            }
            .padding(.horizontal, 28)
        }
        .onAppear { startAll() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Elapsed label

    var elapsedLabel: String {
        if elapsed == 0 { return "Ringing now" }
        if elapsed < 60 { return "Ringing for \(elapsed)s" }
        let m = elapsed / 60
        let s = elapsed % 60
        return s == 0 ? "Ringing for \(m)m" : "Ringing for \(m)m \(s)s"
    }

    // MARK: - Pulse Rings

    var pulseRings: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        Color(hex: "#6B4FD8").opacity(pulse ? 0 : 0.4),
                        lineWidth: 1.5
                    )
                    .frame(
                        width:  155 + CGFloat(i) * 65,
                        height: 155 + CGFloat(i) * 65
                    )
                    .scaleEffect(pulse ? 1.5 : 1.0)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.5),
                        value: pulse
                    )
            }
        }
        .offset(y: -90)
    }

    // MARK: - Buttons

    var buttonsSection: some View {
        VStack(spacing: 14) {

            // Snooze — يظهر فقط إذا كان مفعّلاً في إعدادات المنبه
            if alarm.snoozeEnabled {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        manager.snoozeRingingAlarm()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 18))
                        Text("Snooze  ·  \(alarm.snoozeDuration) min")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                            )
                    )
                }
            }

            // Dismiss
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    manager.dismissRingingAlarm()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Dismiss")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#7A5CE8"), Color(hex: "#4A32B0")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                )
                .shadow(
                    color: Color(hex: "#6B4FD8").opacity(0.55),
                    radius: 14, y: 5
                )
            }
        }
    }

    // MARK: - Start animations + timer

    func startAll() {
        // Entrance animation
        withAnimation(.spring(response: 0.55, dampingFraction: 0.68).delay(0.05)) {
            appeared = true
        }

        // Pulse rings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pulse = true
        }

        // Bell shake — ذهاباً وإياباً بشكل مستمر
        withAnimation(
            .easeInOut(duration: 0.18)
            .repeatForever(autoreverses: true)
        ) {
            bellShake = true
        }

        // Elapsed counter
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - AlarmRingingModifier
// أضف .alarmRingingOverlay() على MainTabView

struct AlarmRingingModifier: ViewModifier {
    @StateObject private var manager = AlarmManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content
            if let alarm = manager.ringingAlarm {
                AlarmRingingView(alarm: alarm)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.06)),
                            removal:   .opacity.combined(with: .scale(scale: 0.96))
                        )
                    )
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: manager.ringingAlarm?.id)
    }
}

extension View {
    /// أضف هذا على MainTabView مرة واحدة فقط
    func alarmRingingOverlay() -> some View {
        modifier(AlarmRingingModifier())
    }
}

#Preview {
    AlarmRingingView(alarm: Alarm(
        hour: 7, minute: 0, isAM: true,
        repeatDays: [1, 2, 3, 4, 5],
        ringtone: "Ocean Waves",
        ringtoneURL: "",
        snoozeEnabled: true,
        snoozeDuration: 10
    ))
}

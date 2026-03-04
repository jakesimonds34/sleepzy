import SwiftUI

// MARK: - AlarmRingingView
// =========================================================
// كيفية الاستخدام — سطر واحد فقط في MainTabView:
//
//   TabView(selection: $selection) { ... }
//       .accentColor(.white)
//       .alarmRingingOverlay()   ← أضف هذا
//
// =========================================================

struct AlarmRingingView: View {

    let alarm: Alarm
    @StateObject private var manager = AlarmManager.shared

    @State private var pulse     = false
    @State private var bellAngle = 0.0
    @State private var appeared  = false
    @State private var elapsed   = 0
    @State private var ticker: Timer? = nil

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.18),
                    Color(red: 0.10, green: 0.06, blue: 0.30),
                    Color(red: 0.05, green: 0.04, blue: 0.20)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarsBackgroundView().ignoresSafeArea()

            // Pulse rings
            pulseRings

            VStack(spacing: 0) {
                Spacer()

                // Bell
                bellIcon
                    .scaleEffect(appeared ? 1 : 0.4)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 32)

                // ALARM label
                Text("ALARM")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(5)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 8)

                // Time
                Text(alarm.timeString)
                    .font(.system(size: 78, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer().frame(height: 6)

                // Repeat days
                Text(alarm.repeatLabel)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.45))
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 6)

                // Ringtone
                HStack(spacing: 5) {
                    Image(systemName: "music.note").font(.system(size: 12))
                    Text(alarm.ringtone).font(.system(size: 13))
                }
                .foregroundColor(.white.opacity(0.28))
                .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 20)

                // Elapsed counter
                Text(elapsedText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
                    .monospacedDigit()
                    .opacity(appeared ? 1 : 0)

                Spacer()

                // Buttons
                buttons
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 40)

                Spacer().frame(height: 54)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            // Entrance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.05)) {
                appeared = true
            }
            // Pulse rings
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { pulse = true }
            }
            // Bell shake — يهتز يميناً ويساراً باستمرار
            withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                bellAngle = 16
            }
            // Elapsed ticker
            ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsed += 1
            }
        }
        .onDisappear {
            ticker?.invalidate(); ticker = nil
        }
    }

    // MARK: - Elapsed text
    var elapsedText: String {
        if elapsed == 0 { return "Ringing now..." }
        if elapsed < 60 { return "Ringing for \(elapsed)s" }
        let m = elapsed / 60; let s = elapsed % 60
        return s == 0 ? "Ringing for \(m)m" : "Ringing for \(m)m \(s)s"
    }

    // MARK: - Bell icon
    var bellIcon: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color(red: 0.42, green: 0.31, blue: 0.85).opacity(0.30))
                .frame(width: 148, height: 148)
                .blur(radius: 18)

            // Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.48, green: 0.36, blue: 0.91),
                            Color(red: 0.23, green: 0.16, blue: 0.56)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: Color(red: 0.42, green: 0.31, blue: 0.85).opacity(0.65), radius: 22)

            Image(systemName: "alarm.fill")
                .font(.system(size: 52, weight: .medium))
                .foregroundColor(.white)
                .rotationEffect(.degrees(bellAngle), anchor: .top)
        }
    }

    // MARK: - Pulse rings
    var pulseRings: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        Color(red: 0.42, green: 0.31, blue: 0.85)
                            .opacity(pulse ? 0 : 0.38),
                        lineWidth: 1.5
                    )
                    .frame(
                        width:  150 + CGFloat(i) * 70,
                        height: 150 + CGFloat(i) * 70
                    )
                    .scaleEffect(pulse ? 1.55 : 1.0)
                    .animation(
                        .easeOut(duration: 1.6)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.52),
                        value: pulse
                    )
            }
        }
        .offset(y: -95)
    }

    // MARK: - Buttons
    var buttons: some View {
        VStack(spacing: 14) {

            // Snooze — فقط إذا كان مفعّلاً
            if alarm.snoozeEnabled {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        manager.snoozeRingingAlarm()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "moon.zzz.fill").font(.system(size: 17))
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
                    Image(systemName: "xmark.circle.fill").font(.system(size: 20))
                    Text("Dismiss").font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.48, green: 0.36, blue: 0.91),
                            Color(red: 0.29, green: 0.20, blue: 0.69)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                )
                .shadow(
                    color: Color(red: 0.42, green: 0.31, blue: 0.85).opacity(0.5),
                    radius: 12, y: 5
                )
            }
        }
    }
}

// MARK: - AlarmRingingModifier + View Extension
// أضف .alarmRingingOverlay() على MainTabView مرة واحدة فقط

struct AlarmRingingModifier: ViewModifier {
    @StateObject private var manager = AlarmManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content
            if let alarm = manager.ringingAlarm {
                AlarmRingingView(alarm: alarm)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.04)),
                            removal:   .opacity.combined(with: .scale(scale: 0.97))
                        )
                    )
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: manager.ringingAlarm?.id)
    }
}

extension View {
    func alarmRingingOverlay() -> some View {
        modifier(AlarmRingingModifier())
    }
}

// MARK: - Preview
#Preview {
    AlarmRingingView(alarm: Alarm(
        hour: 7, minute: 0, isAM: true,
        repeatDays: [1,2,3,4,5],
        ringtone: "Ocean Waves", ringtoneURL: "",
        snoozeEnabled: true, snoozeDuration: 10
    ))
}

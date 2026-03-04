import SwiftUI

struct AlarmsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AlarmsViewModel()
    @Binding var selection: Taps
    
    @StateObject private var manager = AlarmManager.shared
    
    @State var showingAddAlarm: Bool = false
    @State private var isOn: Bool = true
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .sheet(isPresented: $showingAddAlarm) {
                AlarmFormView()
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "Alarm", subTitle: "", paddingTop: 0)
                .padding(.horizontal)
            
            if manager.alarms.isEmpty {
                EmptyAlarmsView(showingAddAlarm: $showingAddAlarm)
            } else {
                AlarmsListView(showingAddAlarm: $showingAddAlarm)
            }
        }
    }
}

// MARK: - Empty State
struct EmptyAlarmsView: View {
    @Binding var showingAddAlarm: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                MyImage(source: .asset(.alarmEmpty))
                    .scaledToFill()
                    .frame(height: 244)
                
                VStack(spacing: 8) {
                    Text("No alarms yet")
                        .font(.appRegular(size: 26))
                    
                    Text("Add an alarm to wake up gently and add your day refreshed")
                        .font(.appRegular(size: 20))
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    showingAddAlarm.toggle()
                } label: {
                    HStack {
                        MyImage(source: .asset(.alarmClockIcon))
                            .scaledToFit()
                            .frame(width: 24)
                        
                        Text("Set an alarm")
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
            Spacer()
        }
    }
}

// MARK: - Alarms List
struct AlarmsListView: View {
    @StateObject private var manager = AlarmManager.shared
    @Binding var showingAddAlarm: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Next alarm label
            if let nextAlarm = manager.alarms.filter({ $0.isEnabled }).first {
                let (h, m) = nextAlarm.timeUntilNextAlarm()
                HStack {
                    Text("Alarm in \(h) hours and \(m) minutes")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .transition(.opacity)
            }
            
            // Alarm cards
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(manager.alarms) { alarm in
                        AlarmCardView(alarm: alarm)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // FAB Add button
            Button(action: { showingAddAlarm = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 58, height: 58)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.3, blue: 0.9),
                                Color(red: 0.5, green: 0.25, blue: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 34)
        }
    }
}

// MARK: - Alarm Card
struct AlarmCardView: View {
    let alarm: Alarm
    @StateObject private var manager = AlarmManager.shared
    @State private var showEdit = false
    
    var body: some View {
        Button(action: { showEdit = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(alarm.timeString)
                        .font(.system(size: 38, weight: .light, design: .rounded))
                        .foregroundColor(alarm.isEnabled ? .white : .white.opacity(0.35))
                    
                    Text(alarm.repeatLabel)
                        .font(.system(size: 14))
                        .foregroundColor(alarm.isEnabled ? .white.opacity(0.6) : .white.opacity(0.25))
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in manager.toggleAlarm(alarm) }
                ))
                .labelsHidden()
                .tint(Color(red: 0.45, green: 0.3, blue: 0.9))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                manager.deleteAlarm(alarm)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEdit) {
            AlarmFormView(editingAlarm: alarm)
        }
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    AlarmsView(selection: $selection)
}

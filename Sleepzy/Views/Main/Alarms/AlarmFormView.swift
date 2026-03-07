import SwiftUI

struct AlarmFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = AlarmManager.shared
    
    var editingAlarm: Alarm?
    
    @State private var hour: Int = 8
    @State private var minute: Int = 0
    @State private var isAM: Bool = true
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5]
    
    @State private var ringtone: String = "Default"
    @State private var ringtoneURL: String = ""
    @State private var localSoundFile: String? = nil
    @State private var isDownloadingSound = false
    @State private var showRingtones = false
    
    @State private var snoozeEnabled: Bool = true
    @State private var snoozeDuration: Int = 5
    @State private var showSnoozePicker = false
    
    let snoozeDurations = [1, 2, 5, 10, 15, 20, 30]
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    var isEditing: Bool { editingAlarm != nil }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                AppHeaderView(
                    title: isEditing ? "Edit Alarm" : "New Alarm",
                    subTitle: "", paddingTop: 0
                )
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    timePickerSection
                    repeatSection
                    
                    // RINGTONE
                    settingRow(label: "RINGTONE") {
                        Button(action: { showRingtones = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ringtone)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    if isDownloadingSound {
                                        HStack(spacing: 5) {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                                .tint(Color(hex: "#5BCC8A"))
                                            Text("Preparing sound...")
                                                .font(.system(size: 11))
                                                .foregroundColor(Color(hex: "#5BCC8A"))
                                        }
                                    } else if !ringtoneURL.isEmpty {
                                        HStack(spacing: 4) {
                                            Image(systemName: localSoundFile != nil
                                                  ? "checkmark.circle.fill" : "clock.fill")
                                            .font(.system(size: 10))
                                            Text(localSoundFile != nil ? "Ready ✓" : "Queued")
                                                .font(.system(size: 11))
                                        }
                                        .foregroundColor(Color(hex: "#5BCC8A"))
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    
                    // SNOOZE
                    settingRow(label: "SNOOZE") {
                        HStack {
                            Text("Snooze")
                                .font(.system(size: 16)).foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $snoozeEnabled)
                                .labelsHidden()
                                .tint(Color(red: 0.45, green: 0.3, blue: 0.9))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 15)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(12)
                    }
                    
                    if snoozeEnabled {
                        settingRow(label: "SNOOZE DURATION") {
                            Button(action: { showSnoozePicker = true }) {
                                HStack {
                                    Text("\(snoozeDuration) min")
                                        .font(.system(size: 16)).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.horizontal, 16).padding(.vertical, 15)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Button(action: saveAlarm) { Text("Save Alarm") }
                        .style(.primary)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    
                    if isEditing {
                        Button(action: {
                            if let alarm = editingAlarm {
                                manager.deleteAlarm(alarm)
                                dismiss()
                            }
                        }) {
                            Text("Delete Alarm")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 1, green: 0.35, blue: 0.35))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color(red: 1, green: 0.35, blue: 0.35).opacity(0.1))
                                .cornerRadius(30)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(
            MyImage(source: .asset(.bgSounds))
                .scaledToFill()
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showRingtones, onDismiss: {
            SleepSoundPlayer.shared.stop()
        }) {
            SleepSoundsPickerSheet(
                selectedName: $ringtone,
                selectedURL: $ringtoneURL,
                onSelected: { name, url in
                    ringtone          = name
                    ringtoneURL       = url
                    localSoundFile    = nil
                    isDownloadingSound = true
                    // ✅ حمّل الصوت فوراً من Supabase Cache
                    let alarmId = editingAlarm?.id.uuidString ?? UUID().uuidString
                    AlarmSoundManager.shared.downloadAndPrepare(
                        url: url, alarmId: alarmId
                    ) { fileName in
                        localSoundFile     = fileName
                        isDownloadingSound = false
                    }
                }
            )
        }
        .sheet(isPresented: $showSnoozePicker) {
            SnoozeDurationPicker(selected: $snoozeDuration, options: snoozeDurations)
        }
        .onAppear { loadEditingData() }
    }
    
    // MARK: - Time Picker
    var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TIME")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.45)).tracking(1)
            
            HStack(spacing: 6) {
                TimeDigitPicker(value: hour / 10, range: 0...1, onUp: {
                    let newVal = (hour / 10 + 1) % 2
                    hour = newVal * 10 + (hour % 10)
                    if hour == 0 { hour = 1 }
                    if hour > 12 { hour = 12 }
                }, onDown: {
                    let newVal = hour / 10 == 0 ? 1 : 0
                    hour = newVal * 10 + (hour % 10)
                    if hour == 0 { hour = 1 }
                    if hour > 12 { hour = 12 }
                })
                
                TimeDigitPicker(value: hour % 10, range: 0...9, onUp: {
                    let ones = (hour % 10 + 1) % 10
                    var newHour = (hour / 10) * 10 + ones
                    if newHour == 0 { newHour = 10 }
                    if newHour > 12 { newHour = 1 }
                    hour = newHour
                }, onDown: {
                    let ones = hour % 10 == 0 ? 9 : (hour % 10 - 1)
                    var newHour = (hour / 10) * 10 + ones
                    if newHour == 0 { newHour = 12 }
                    if newHour > 12 { newHour = 12 }
                    hour = newHour
                })
                
                Text(":")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 16)
                
                TimeDigitPicker(value: minute / 10, range: 0...5, onUp: {
                    minute = ((minute / 10 + 1) % 6) * 10 + (minute % 10)
                }, onDown: {
                    let tens = minute / 10 == 0 ? 5 : (minute / 10 - 1)
                    minute = tens * 10 + (minute % 10)
                })
                
                TimeDigitPicker(value: minute % 10, range: 0...9, onUp: {
                    minute = (minute / 10) * 10 + (minute % 10 + 1) % 10
                }, onDown: {
                    let ones = minute % 10 == 0 ? 9 : (minute % 10 - 1)
                    minute = (minute / 10) * 10 + ones
                })
                
                VStack(spacing: 6) {
                    Button("AM") { withAnimation { isAM = true } }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isAM ? .white : .white.opacity(0.3))
                        .frame(width: 52, height: 44)
                        .background(isAM ? Color(hex: "#5939A8").opacity(0.2) : Color.white.opacity(0.03))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color(hex: "#988AE1").opacity(0.2), lineWidth: 1))
                    
                    Button("PM") { withAnimation { isAM = false } }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(!isAM ? .white : .white.opacity(0.3))
                        .frame(width: 52, height: 44)
                        .background(!isAM ? Color(hex: "#5939A8").opacity(0.2) : Color.white.opacity(0.03))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color(hex: "#988AE1").opacity(0.2), lineWidth: 1))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Repeat Section
    var repeatSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REPEAT ON")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.45)).tracking(1)
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    let isSelected = selectedDays.contains(day)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isSelected { selectedDays.remove(day) }
                            else { selectedDays.insert(day) }
                        }
                    }) {
                        Text(days[day - 1])
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                            .frame(maxWidth: .infinity).frame(height: 42)
                            .background(isSelected
                                ? Color(hex: "#5939A8").opacity(0.2) : Color.white.opacity(0.03))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color(hex: "#988AE1").opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
    }
    
    func settingRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.45)).tracking(1)
            content()
        }
    }
    
    // MARK: - Load Editing Data
    func loadEditingData() {
        guard let alarm = editingAlarm else {
            SleepSoundPlayer.shared.selectedAlarmSoundId = nil
            return
        }
        hour           = alarm.hour
        minute         = alarm.minute
        isAM           = alarm.isAM
        selectedDays   = alarm.repeatDays
        ringtone       = alarm.ringtone
        ringtoneURL    = alarm.ringtoneURL
        localSoundFile = alarm.localSoundFile
        snoozeEnabled  = alarm.snoozeEnabled
        snoozeDuration = alarm.snoozeDuration

        // ✅ عيّن الصوت المختار بناءً على Supabase أو My Sounds
        if !alarm.ringtoneURL.isEmpty {
            let allSounds = SupabaseManager.shared.sounds +
                MySoundsManager.shared.sounds.map { $0.asSleepSound }
            if let match = allSounds.first(where: { $0.fileURL == alarm.ringtoneURL }) {
                SleepSoundPlayer.shared.selectedAlarmSoundId = match.id
            } else {
                SleepSoundPlayer.shared.selectedAlarmSoundId = nil
            }
        } else {
            SleepSoundPlayer.shared.selectedAlarmSoundId = nil
        }
    }
    
    // MARK: - Save
    func saveAlarm() {
        var alarm = Alarm(
            hour: hour, minute: minute, isAM: isAM,
            repeatDays: selectedDays, ringtone: ringtone,
            ringtoneURL: ringtoneURL, snoozeEnabled: snoozeEnabled,
            snoozeDuration: snoozeDuration
        )
        if let existing = editingAlarm {
            alarm.id        = existing.id
            alarm.isEnabled = existing.isEnabled
            if ringtoneURL == existing.ringtoneURL {
                alarm.localSoundFile = localSoundFile ?? existing.localSoundFile
            } else {
                AlarmSoundManager.shared.deleteSound(fileName: existing.localSoundFile)
                alarm.localSoundFile = localSoundFile
            }
            manager.updateAlarm(alarm)
        } else {
            alarm.localSoundFile = localSoundFile
            manager.addAlarm(alarm)
        }
        SleepSoundPlayer.shared.stop()
        SleepSoundPlayer.shared.selectedAlarmSoundId = nil
        dismiss()
    }
}

// MARK: - SleepSoundsPickerSheet
struct SleepSoundsPickerSheet: View {
    @Binding var selectedName: String
    @Binding var selectedURL: String
    var onSelected: ((String, String) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.16).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Choose Ringtone")
                        .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(hex: "#7A6AE0"))
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                SleepSoundsView(
                    selection: .constant(.sounds),
                    alarmSelectionMode: true,
                    onSoundSelected: { sound in
                        selectedName = sound.name
                        selectedURL  = sound.fileURL
                        onSelected?(sound.name, sound.fileURL)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
                    }
                )
            }
        }
    }
}

// MARK: - TimeDigitPicker
struct TimeDigitPicker: View {
    let value: Int
    let range: ClosedRange<Int>
    let onUp: () -> Void
    let onDown: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onUp) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35)).frame(height: 22)
            }
            Text("\(value)")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.03))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 1))
            Button(action: onDown) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35)).frame(height: 22)
            }
        }
    }
}

// MARK: - SnoozeDurationPicker
struct SnoozeDurationPicker: View {
    @Binding var selected: Int
    let options: [Int]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.22).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Snooze Duration")
                        .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.9))
                        .font(.system(size: 17, weight: .medium))
                }
                .padding(.horizontal, 24).padding(.vertical, 20)
                
                ForEach(options, id: \.self) { option in
                    Button(action: { selected = option }) {
                        HStack {
                            Text("\(option) minutes")
                                .font(.system(size: 17)).foregroundColor(.white)
                            Spacer()
                            if selected == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.9))
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .padding(.horizontal, 24).padding(.vertical, 16)
                        .background(selected == option ? Color.white.opacity(0.06) : Color.clear)
                    }
                    Divider().background(Color.white.opacity(0.08))
                }
                Spacer()
            }
        }
    }
}

#Preview { AlarmFormView() }

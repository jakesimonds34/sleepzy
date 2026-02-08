//
//  NewAlarmView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 08/02/2026.
//

import SwiftUI
struct NewAlarmView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AlarmsViewModel()
    
    @State private var alarmTime: Date = Date()
    
    @State private var repeatDays: [String: Bool] = [
        "M": true, "T": true, "W": true, "T2": true, "F": true, "S": false, "S2": false
    ]
    
    @State private var ringtone: String = "Brown Calm"
    @State private var snoozeEnabled: Bool = true
    @State private var snoozeDuration: Int = 5
    
    // MARK: - Helpers
    var dayKeys: [String] { ["M", "T", "W", "T2", "F", "S", "S2"] }
    
    func dayLabel(for key: String) -> String {
        switch key {
        case "M": return "M"
        case "T": return "T"
        case "W": return "W"
        case "T2": return "T"
        case "F": return "F"
        case "S": return "S"
        case "S2": return "S"
        default: return ""
        }
    }
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        ZStack {
            Button {
                dismiss()
            } label: {
                MyImage(source: .system("xmark", renderingMode: .template))
                    .tint(.white)
                    .frame(width: 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing)
                    .padding(.top, 25)
            }

            
            VStack {
                Text("New Alarm")
                    .font(.appRegular(size: 24))
                
                ScrollView {
                    // MARK: - Time Picker
                    VStack(alignment: .center, spacing: 8) {
                        HStack {
                            Text("TIME")
                                .font(.appRegular14)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        DatePicker("",
                                   selection: $alarmTime,
                                   displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    
                    // MARK: - Repeat Days
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("REPEAT ON")
                                .font(.appRegular14)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        HStack {
                            ForEach(dayKeys, id: \.self) { key in
                                let label = dayLabel(for: key)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(repeatDays[key]! ?
                                          Color(hex: "5939A8").opacity(0.2) : Color.white.opacity(0.1))
                                    .stroke(repeatDays[key]! ?
                                            Color(hex: "988AE1").opacity(0.4) : .white.opacity(0.2), lineWidth: 1)
                                    .frame(width: 44, height: 44)
                                    .overlay(Text(label).foregroundColor(.white))
                                    .onTapGesture {
                                        withAnimation {
                                            repeatDays[key]?.toggle()
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // MARK: - Ringtone
                    VStack(alignment: .leading) {
                        Text("RINGTONE")
                            .font(.appRegular14)
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: RingtonePicker(selected: $ringtone)) {
                            HStack {
                                Text(ringtone)
                                    .foregroundColor(.white)
                                    .font(.appMedium18)
                                
                                Spacer()
                                MyImage(source: .system("chevron.right", renderingMode: .template))
                                    .frame(width: 6)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal)
                            .frame(height: 54)
                            .background(.white.opacity(0.05))
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Snooze
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SNOOZE")
                            .font(.appRegular14)
                            .foregroundColor(.white)
                        
                        Toggle("Snooze", isOn: $snoozeEnabled)
                            .padding(.horizontal)
                            .frame(height: 54)
                            .background(.white.opacity(0.05))
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                            .font(.appMedium18)
                            .tint(Color(hex: "5939A8"))
                        
                        if snoozeEnabled {
                            Text("SNOOZE DURATION")
                                .font(.appRegular14)
                                .foregroundColor(.white)
                            
                            Stepper(value: $snoozeDuration, in: 1...15) {
                                Text("Snooze Duration: \(snoozeDuration) min")
                            }
                            .padding(.horizontal)
                            .frame(height: 54)
                            .background(.white.opacity(0.05))
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                            .font(.appMedium18)
                        }
                    }
                    
                    // MARK: - Save Button
                    Button(action: saveAlarm) {
                        Text("Save Alarm")
                    }
                    .style(.primary)
                    .padding(.top, 10)
                }
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    func saveAlarm() {
        print("Alarm saved!")
        dismiss()
    }
}

struct RingtonePicker: View {
    @Binding var selected: String
    let tones = ["Brown Calm", "Soft Breeze", "Morning Light", "Digital Beep"]
    
    var body: some View {
        List {
            ForEach(tones, id: \.self) { tone in
                HStack {
                    Text(tone)
                    Spacer()
                    if tone == selected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selected = tone
                }
            }
        }
        .navigationTitle("Ringtone")
    }
}

/*
struct NewAlarmView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var alarmTime: Date = Date()
    @State private var repeatDays: [String: Bool] = [
        "M": true, "T": true, "W": true, "T2": true, "F": true, "S": false, "S2": false
    ]
    @State private var ringtone: String = "Brown Calm"
    @State private var snoozeEnabled: Bool = true
    @State private var snoozeDuration: Int = 5
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            Text("New Alarm")
                .font(.title2.bold())
                .padding(.bottom, 5)
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: - Time Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIME")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        DatePicker("",
                                   selection: $alarmTime,
                                   displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    
                    // MARK: - Repeat Days
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REPEAT ON")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            ForEach(dayKeys, id: \.self) { key in
                                let label = dayLabel(for: key)
                                Circle()
                                    .fill(repeatDays[key]! ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 36, height: 36)
                                    .overlay(Text(label).foregroundColor(.white))
                                    .onTapGesture {
                                        withAnimation {
                                            repeatDays[key]?.toggle()
                                        }
                                    }
                            }
                        }
                    }
                    
                    // MARK: - Ringtone
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RINGTONE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: RingtonePicker(selected: $ringtone)) {
                            HStack {
                                Text("Ringtone")
                                Spacer()
                                Text(ringtone)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // MARK: - Snooze
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SNOOZE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Toggle("Snooze", isOn: $snoozeEnabled)
                        
                        if snoozeEnabled {
                            Stepper(value: $snoozeDuration, in: 1...15) {
                                Text("Snooze Duration: \(snoozeDuration) min")
                            }
                        }
                    }
                    
                    // MARK: - Save Button
                    Button(action: saveAlarm) {
                        Text("Save Alarm")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(25, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Helpers
    var dayKeys: [String] { ["M", "T", "W", "T2", "F", "S", "S2"] }
    
    func dayLabel(for key: String) -> String {
        switch key {
        case "M": return "M"
        case "T": return "T"
        case "W": return "W"
        case "T2": return "T"
        case "F": return "F"
        case "S": return "S"
        case "S2": return "S"
        default: return ""
        }
    }
    
    func saveAlarm() {
        print("Alarm saved!")
        dismiss()
    }
}

struct RingtonePicker: View {
    @Binding var selected: String
    let tones = ["Brown Calm", "Soft Breeze", "Morning Light", "Digital Beep"]
    
    var body: some View {
        List {
            ForEach(tones, id: \.self) { tone in
                HStack {
                    Text(tone)
                    Spacer()
                    if tone == selected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selected = tone
                }
            }
        }
        .navigationTitle("Ringtone")
    }
}
*/

#Preview {
    NavigationStack {
        NewAlarmView()
    }
}

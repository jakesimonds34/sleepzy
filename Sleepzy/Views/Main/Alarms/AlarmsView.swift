//
//  AlarmsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct AlarmsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AlarmsViewModel()
    @Binding var selection: Taps
    
    @State var showNewAlarm: Bool = false
    @State private var isOn: Bool = true
    
    let isEmpty: Bool = true
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .sheet(isPresented: $showNewAlarm) {
                NewAlarmView()
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "Alarm", subTitle: "", paddingTop: 0)
                .padding(.horizontal)
            
            if isEmpty {
                emptyData()
            } else {
                alarmsView()
                    .padding(.top, 30)
            }
        }
    }
    
    //MARK: Empty data
    private func emptyData() -> some View {
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
                    showNewAlarm.toggle()
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
    
    @ViewBuilder
    private func alarmsView() -> some View {
        VStack(alignment: .leading, spacing: 30) {
            // MARK: - Alarm Remaining Time
            Text("Alarm in 10 hours and 30 minutes")
                .font(.appRegular(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // MARK: - Time
                        Text("10:30")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        // MARK: - Days
                        Text("Monday to Friday")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    // MARK: - Toggle
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(Color(hex: "5939A8"))
                }
                .padding()
                .background(.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    AlarmsView(selection: $selection)
}

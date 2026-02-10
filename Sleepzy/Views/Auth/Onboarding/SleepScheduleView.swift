//
//  SleepScheduleView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import SwiftUI

struct SleepScheduleView: View {
    // MARK: - Properties
    @Binding var currentStep: Double
    @Binding var bedHour: Double
    @Binding var wakeHour: Double
    
    // MARK: - Body
    var body: some View {
        content
            .onChange(of: bedHour) { (_, newValue) in
                print(newValue)
            }
            .onChange(of: wakeHour) { (_, newValue) in
                print(newValue)
            }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            AppHeaderView(title: "Select your sleep schedule",
                          subTitle: "Consistency matters. Your body loves predictability when it comes to sleep.",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            SleepEditorView(bedHour: $bedHour, wakeHour: $wakeHour)
        }
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.2
    @Previewable @State var bedHour: Double = 22
    @Previewable @State var wakeHour: Double = 8
    SleepScheduleView(currentStep: $currentStep, bedHour: $bedHour, wakeHour: $wakeHour)
}


struct SleepEditorView: View {
    
    @Binding var bedHour: Double     // 10 PM
    @Binding var wakeHour: Double     // 8 AM
    
    var sleepDuration: Double {
        let diff = wakeHour - bedHour
        return diff >= 0 ? diff : (24 + diff)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    let lineWidth = size * 0.08
                    let radius = size / 2
                    
                    ZStack {
                        
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
                        
                        SleepArcShape(startHour: bedHour, endHour: wakeHour)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.white
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                        
                        SleepHandle(
                            icon: .moonIcon,
                            hour: bedHour,
                            color: .yellow,
                            size: size
                        ) { newHour in
                            bedHour = newHour
                        }
                        
                        SleepHandle(
                            icon: .sunIcon,
                            hour: wakeHour,
                            color: .orange,
                            size: size
                        ) { newHour in
                            wakeHour = newHour
                        }
                        
                        ClockLabels(radius: radius)
                        
                        /*
                        VStack(spacing: 6) {
                            Text("Sleep time")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(Int(sleepDuration))h \(Int((sleepDuration - floor(sleepDuration)) * 60))m")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        */
                    }
                    .frame(width: size, height: size)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                }
                .frame(height: 275)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .center) {
                        MyImage(source: .asset(.moonIcon, renderingMode: .template))
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Text("Bed time")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formatHour(bedHour))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Sleep time")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(Int(sleepDuration)) hours")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    VStack(alignment: .center) {
                        MyImage(source: .asset(.sunIcon, renderingMode: .template))
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Text("Wake up")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formatHour(wakeHour))
                            .foregroundColor(.white)
                    }
                }
                .font(.appRegular16)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    func formatHour(_ hour: Double) -> String {
        let h = Int(hour) % 24
        let suffix = h >= 12 ? "PM" : "AM"
        let display = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return "\(display):00 \(suffix)"
    }
}

struct SleepArcShape: Shape {
    let startHour: Double
    let endHour: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        func angle(for hour: Double) -> Angle {
            Angle.degrees((hour / 24) * 360 - 90)
        }
        
        let start = angle(for: startHour)
        let end = angle(for: endHour)
        
        if endHour < startHour {
            path.addArc(center: center, radius: radius, startAngle: start, endAngle: .degrees(270), clockwise: false)
            path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: end, clockwise: false)
        } else {
            path.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        }
        
        return path
    }
}

struct SleepHandle: View {
    let icon: ImageResource
    let hour: Double
    let color: Color
    let size: CGFloat
    let onChange: (Double) -> Void
    
    var body: some View {
        GeometryReader { geo in
            let radius = size / 2
            let angle = Angle.degrees((hour / 24) * 360 - 90).radians
            
            let x = radius + cos(angle) * radius
            let y = radius + sin(angle) * radius
            
            MyImage(source: .asset(icon, renderingMode: .template))
                .foregroundStyle(Color(hex: "1B1A58"))
                .frame(width: 20, height: 20)
                .padding(10)
                .background(Circle().fill(Color.white))
                .overlay(Circle().stroke(Color(hex: "454568"), lineWidth: 1))
                .position(x: x, y: y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dx = value.location.x - radius
                            let dy = value.location.y - radius
                            let angle = atan2(dy, dx) + .pi/2
                            var degrees = angle * 180 / .pi
                            if degrees < 0 { degrees += 360 }
                            let hour = (degrees / 360) * 24
                            onChange(hour)
                        }
                )
        }
    }
}

struct ClockLabels: View {
    let radius: CGFloat
    
    var body: some View {
        ZStack {
            clockLabel(text: "12:00 AM", hour: 0)
            clockLabel(text: "2", hour: 2)
            clockLabel(text: "4", hour: 4)
            clockLabel(text: "6:00 AM",  hour: 6)
            clockLabel(text: "8", hour: 8)
            clockLabel(text: "10", hour: 10)
            clockLabel(text: "12:00 PM", hour: 12)
            clockLabel(text: "2", hour: 14)
            clockLabel(text: "4", hour: 16)
            clockLabel(text: "6:00 PM",  hour: 18)
            clockLabel(text: "8", hour: 20)
            clockLabel(text: "10", hour: 22)
        }
    }
    
    func clockLabel(text: String, hour: Double) -> some View {
        let angle = Angle.degrees((hour / 24) * 360 - 90).radians
        let labelRadius = radius * 0.70
        
        let x = cos(angle) * labelRadius
        let y = sin(angle) * labelRadius
        
        return Text(text)
            .font(.appRegular12)
            .foregroundColor(.white.opacity(0.7))
            .position(x: radius + x, y: radius + y)
    }
}

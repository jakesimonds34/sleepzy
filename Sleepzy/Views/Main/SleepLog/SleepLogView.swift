//
//  SleepLogView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct SleepLogView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SleepLogViewModel()
    @Binding var selection: Taps
    
    @State private var selectedRange = "Weekly"
    
    private let ranges = ["Weekly", "Monthly", "Yearly"]
    
    private let days: [(date: String, start: String, end: String, time: String, quality: String)] = [
        ("8 Feb", "12:20 AM", "7:00 AM", "7h 20m", "Good"),
        ("7 Feb", "12:20 AM", "6:40 AM", "6h 20m", "Good"),
        ("6 Feb", "12:20 AM", "7:00 AM", "7h 12m", "Good")
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .background(
                    MyImage(source: .asset(.bgSounds))
                        .scaledToFill()
                        .ignoresSafeArea()
                )
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            AppHeaderView(title: "Sleep log", subTitle: "", paddingTop: 0)
            
            // Range Selector
            HStack {
                ForEach(ranges, id: \.self) { range in
                    Button {
                        selectedRange = range
                    } label: {
                        HStack {
                            Spacer()
                            Text(range)
                                .font(.appMedium14)
                                .frame(height: 36)
                            Spacer()
                        }
                        .background(
                            selectedRange == range ?
                            Color(hex: "5939A8") : .clear
                        )
                        .cornerRadius(6)
                        .foregroundColor(
                            selectedRange == range ? .white : .white.opacity(0.5)
                        )
                    }
                }
            }
            
            HStack {
                MyImage(source: .system("chevron.left"))
                    .frame(width: 8)
                
                Spacer()
                Text("2 - 8 Feb")
                    .foregroundColor(.white)
                    .font(.appMedium20)
                Spacer()
                
                MyImage(source: .system("chevron.right"))
                    .frame(width: 8)
            }
            
            // Stats
            HStack(spacing: 20) {
                statCard(icon: .sleepIcon, title: "Avg Sleep:", value: "6h 58m", change: "+5%")
                statCard(icon: .percentIcon, title: "Sleep Quality", value: "85%", change: "+5%")
            }
            
            // Daily Logs
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(days, id: \.date) { day in
                        dayRow(day)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Stat Card
    private func statCard(icon: ImageResource, title: String, value: String, change: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            VStack(alignment: .leading, spacing: 16) {
                MyImage(source: .asset(icon))
                    .scaledToFit()
                    .frame(width: 32)
                
                Text(title)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.appRegular16)
            }
            
            HStack {
                Text(value)
                    .foregroundColor(.white)
                    .font(.appBold24)
                
                HStack(spacing: 0) {
                    Text(change)
                        .font(.appRegular14)
                    Image(systemName: "arrow.up")
                        .font(.appBold10)
                }
                .foregroundColor(Color(hex: "17B26A"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
    
    // MARK: - Day Row
    private func dayRow(_ day: (date: String, start: String, end: String, time: String, quality: String)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(day.start) - \(day.end)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.appRegular(size: 18))
                    
                }
                
                Spacer()
                Text(day.date)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.appRegular16)
            }
            
            HStack {
                Text(day.time)
                    .font(.appMedium24)
                
                Spacer()
                Circle()
                    .stroke(lineWidth: 1)
                    .frame(width: 14)
                    .foregroundStyle(Color(hex: "08CE08"))
                Text(day.quality)
                    .font(.appRegular16)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SleepLogView(selection: $selection)
}

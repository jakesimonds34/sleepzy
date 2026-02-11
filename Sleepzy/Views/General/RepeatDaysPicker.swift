//
//  RepeatDaysPicker.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI
import Combine

enum WeekDay: String, CaseIterable, Identifiable {
    case monday = "M"
    case tuesday = "T"
    case wednesday = "W"
    case thursday = "T2"
    case friday = "F"
    case saturday = "S"
    case sunday = "S2"
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
}

class RepeatDaysModel: ObservableObject {
    @Published var selected: [WeekDay: Bool] = {
        var dict: [WeekDay: Bool] = [:]
        WeekDay.allCases.forEach { dict[$0] = false }
        return dict
    }()
    
    func toggle(_ day: WeekDay) {
        selected[day]?.toggle()
    }
}

struct RepeatDaysPicker: View {
    @ObservedObject var model: RepeatDaysModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("REPEAT ON")
                .font(.appRegular14)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(WeekDay.allCases) { day in
                    let isSelected = model.selected[day] ?? false
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ?
                              Color(hex: "5939A8").opacity(0.2) :
                              Color.white.opacity(0.1))
                        .stroke(isSelected ?
                                Color(hex: "988AE1").opacity(0.4) :
                                .white.opacity(0.2),
                                lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(day.label)
                                .foregroundColor(.white)
                        )
                        .onTapGesture {
                            withAnimation {
                                model.toggle(day)
                            }
                        }
                }
            }
        }
    }
}

func repeatDaysToJSON(_ repeatDays: [WeekDay: Bool]) -> [String: Bool] {
    var json: [String: Bool] = [:]
    repeatDays.forEach { key, value in
        json[key.rawValue] = value
    }
    return json
}

//
//  FocusProtectionScheduleView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI

struct FocusProtectionScheduleView: View {
    // MARK: - Properties
    @Binding var repeatModel: RepeatDaysModel
    @Binding var currentStep: Double
    
    @Binding var fromTime: Date
    @Binding var toTime: Date
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack {
            AppHeaderView(title: "When should Sleepzy protect your focus?",
                          subTitle: "Choose when distracting apps are blocked to help you sleep better.",
                          isBack: false,
                          paddingTop: 16)
            .padding(.horizontal)
            
            // MARK: - From - TO Time Picker
            TimePickerView(time: $fromTime, title: "FROM")
            TimePickerView(time: $toTime, title: "TO")
            
            //MARK: Repeate Days Picker
            RepeatDaysPicker(model: repeatModel)
        }
    }
}

#Preview {
    @Previewable @State var repeatModel = RepeatDaysModel()
    @Previewable @State var currentStep: Double = 0.1
    @Previewable @State var fromTime: Date = Date()
    @Previewable @State var toTime: Date = Date()
    FocusProtectionScheduleView(repeatModel: $repeatModel, currentStep: $currentStep, fromTime: $fromTime, toTime: $toTime)
}

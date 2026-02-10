//
//  TimePickerView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 10/02/2026.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var time: Date
    var title: String = "TIME"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.appRegular14)
                .foregroundColor(.white)
            
            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

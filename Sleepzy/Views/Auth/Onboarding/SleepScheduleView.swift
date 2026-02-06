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
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        Text("Goals")
            .foregroundStyle(.white)
    }
}

#Preview {
    @Previewable @State var currentStep: Double = 0.2
    SleepScheduleView(currentStep: $currentStep)
}

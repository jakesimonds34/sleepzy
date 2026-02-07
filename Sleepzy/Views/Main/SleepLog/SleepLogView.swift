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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        Text("Sleep Log")
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SleepLogView(selection: $selection)
}

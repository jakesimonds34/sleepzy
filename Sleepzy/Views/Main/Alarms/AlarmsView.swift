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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        Text("Alarms")
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    AlarmsView(selection: $selection)
}

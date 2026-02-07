//
//  SettingsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SettingsViewModel()
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
        Text("Settings")
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SettingsView(selection: $selection)
}

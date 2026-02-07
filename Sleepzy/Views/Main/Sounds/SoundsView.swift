//
//  SoundsView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct SoundsView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SoundsViewModel()
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
        Text("Sounds")
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SoundsView(selection: $selection)
}

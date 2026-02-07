//
//  HomeView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
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
        Text("Home")
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    HomeView(selection: $selection)
}

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
    
    @State private var selectedCategory: String = "All"
    @State private var currentlyPlaying: String? = "Ocean waves"
    
    private let categories = ["All", "Nature", "White Noise", "Space"]
    
    private let sounds: [(name: String, category: String, image: String)] = [
        ("Ocean waves", "Nature", "wave.3.forward"),
        ("Ocean Drift", "Nature", "water.waves"),
        ("Brown Calm", "White Noise", "wind"),
        ("Pink Hush", "White Noise", "fanblades"),
        ("Stellar Flow", "White Noise", "sparkles"),
        ("Nebula Whisper", "Space", "moon.stars")
    ]
    
    // MARK: - Body
    var body: some View {
        content
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppHeaderView(title: "Sleep Sounds", subTitle: "", paddingTop: 0)
                .padding(.horizontal)
            
            // Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.appRegular14)
                                .padding(.horizontal, 20)
                                .frame(height: 28)
                                .background(
                                    selectedCategory == category ?
                                    Color(hex: "5939A8").opacity(0.1) : .white.opacity(0.05)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            selectedCategory == category ?
                                            Color(hex: "5939A8") : Color.white.opacity(0.3), lineWidth: 1
                                        )
                                )
                                .cornerRadius(20)
                                .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Sound List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(filteredSounds(), id: \.name) { sound in
                        soundRow(sound)
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
    // MARK: - Filter Logic
    private func filteredSounds() -> [(name: String, category: String, image: String)] {
        if selectedCategory == "All" {
            return sounds
        }
        return sounds.filter { $0.category == selectedCategory }
    }
    
    // MARK: - Sound Row
    @ViewBuilder
    private func soundRow(_ sound: (name: String, category: String, image: String)) -> some View {
        HStack(spacing: 16) {
            Image(systemName: sound.image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.name)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text(sound.category)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button {
                togglePlay(sound.name)
            } label: {
                MyImage(source: .asset(currentlyPlaying == sound.name ? .pauseIcon : .playIcon))
                    .scaledToFit()
                    .frame(width: 30)
            }
        }
        .padding()
        .background( currentlyPlaying == sound.name ? Color(hex: "5939A8").opacity(0.2) : Color.white.opacity(0.05) )
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    // MARK: - Play Logic
    private func togglePlay(_ name: String) {
        if currentlyPlaying == name {
            currentlyPlaying = nil
        } else {
            currentlyPlaying = name
        }
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SoundsView(selection: $selection)
}

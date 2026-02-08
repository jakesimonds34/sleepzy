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
    @State var isPlaying: Bool = false
    @State var isEnabled: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            content
        }
        .background(
            MyImage(source: .asset(.bgHome))
                .scaledToFill()
        )
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            headerView()
            sleepLastView()
            
            seeAllView()
            
            digitalShildView()
        }
        .padding(.vertical, 77)
        .padding(.horizontal, 16)
    }
    
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tuesday, February 3")
                .font(.appRegular14)
                .foregroundStyle(.white.opacity(0.6))
            
            Text("Good evening")
                .font(.appRegular(size: 34))
            
            Text("Sleep Mode")
                .font(.appMedium20)
                .padding(.top, 22)
            
            HStack(spacing: 5) {
                MyImage(source: .asset(.moonIcon, renderingMode: .template))
                    .scaledToFit()
                    .frame(width: 20)
                
                Text("Sleep Schedule")
                    .font(.appRegular16)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("10:00 PM")
                    .font(.appRegular(size: 18))
                
                Spacer()
            }
            .padding(.top, 16)
            
            Button {
                
            } label: {
                HStack {
                    MyImage(source: .asset(.windIcon))
                        .scaledToFit()
                        .frame(width: 24)
                    
                    Text("Start Wind-Down")
                        .font(.appRegular16)
                }
                .frame(height: 44)
                .padding(.horizontal, 15)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#322C94"),
                                 Color(hex: "#58359E"),
                                 Color(hex: "#58359E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(9)
            }
            .padding(.top, 20)

        }
    }
    
    private func sleepLastView() -> some View {
        HStack(spacing: 11) {
            MyImage(source: .asset(.sleepIcon, renderingMode: .template))
                .scaledToFit()
                .frame(width: 16)
            
            Spacer()
            
            Text("Sleep Last Night")
                .foregroundStyle(.white.opacity(0.2))
            
            Rectangle()
                .fill(.white)
                .frame(width: 1, height: 16)
            
            Circle()
                .fill(.clear)
                .stroke(Color(hex: "#08CE08"), lineWidth: 1)
                .frame(width: 14, height: 14)
            
            Text("7 Hr 15 min")
        }
        .font(.appRegular16)
        .frame(height: 43)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#1B113380").opacity(0.5),
                         Color(hex: "#58359E").opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(9)
    }
    
    @ViewBuilder
    private func seeAllView() -> some View {
        HStack {
            Text("Sleep Sounds")
                .font(.appRegular(size: 20))
            
            Spacer()
            
            Button {
                selection = .sounds
            } label: {
                Text("View All")
                    .underline()
                    .font(.appRegular(size: 13))
            }

        }
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<4) { _ in
                sleepSoundCardView()
            }
        }
    }
    
    private func sleepSoundCardView() -> some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .overlay {
                    // MyImage(source: .asset(.bg))
                    //     .scaledToFill()
                }
            
            VStack {
                Button {
                    
                } label: {
                    MyImage(source: .asset(isPlaying ? .pauseIcon : .playIcon))
                        .scaledToFit()
                        .frame(width: 50)
                }
                
                Text("Soft Rain")
            }
        }
        .frame(height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func digitalShildView() -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#322C94"),
                                 Color(hex: "#58359E")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay {
                    MyImage(source: .asset(.shieldIcon))
                        .scaledToFit()
                        .frame(width: 24)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Digital Shield")
                    .font(.appRegular(size: 20))
                
                Text("Active in 15 Min • 13 Apps Blocked")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.appRegular14)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6C5CE7")))
        }
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    HomeView(selection: $selection)
}

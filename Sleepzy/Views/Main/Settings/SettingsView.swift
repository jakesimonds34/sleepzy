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
    
    @State private var notificationEnabled: Bool = true
    @State private var digitalShieldEnabled: Bool = true
    
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
        VStack {
            AppHeaderView(title: "Settings", subTitle: "", paddingTop: 0)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    //MARK: User Info
                    VStack(spacing: 11) {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 80)
                                .overlay {
                                    Text("JS")
                                        .font(.appBold32)
                                }
                            
                            Text("Jake Simonds")
                                .font(.appMedium24)
                            
                            HStack {
                                Text("Sleep Goal: ")
                                    .font(.appRegular16)
                                Text("Better Sleep")
                                    .font(.appMedium24)
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            Text("View Profile")
                                .underline()
                                .foregroundStyle(.white)
                                .font(.appMedium16)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.05))
                    .cornerRadius(16)
                    
                    //MARK: Digital Shield
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DiGITAL SHIELD")
                            .font(.appRegular14)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("13 Apps Blocked")
                                
                                Spacer()
                                MyImage(source: .system("chevron.right", renderingMode: .template))
                                    .frame(width: 6)
                            }
                            .roundedView()
                        }
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Schedule
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SCHEDULE")
                            .font(.appRegular14)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("10:00 PM to 08:00 AM")
                                
                                Spacer()
                                MyImage(source: .system("chevron.right", renderingMode: .template))
                                    .frame(width: 6)
                            }
                            .roundedView()
                        }
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Schedule
                    VStack(alignment: .leading, spacing: 0) {
                        Text("NOTIFICATION")
                            .font(.appRegular14)
                        
                        Toggle("Wind Down", isOn: $notificationEnabled)
                            .roundedView()
                        
                        Toggle("Digital Shield", isOn: $digitalShieldEnabled)
                            .roundedView()
                    }
                    .foregroundColor(.white)
                    
                    //MARK: DATA SYNC
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DATA SYNC")
                            .font(.appRegular14)
                        
                        Toggle("Apple Health", isOn: $notificationEnabled)
                            .roundedView()
                    }
                    .foregroundColor(.white)
                    
                    //MARK: Log Out
                    Button {
                        AppEnvironment.shared.appStatus = .loading
                    } label: {
                        HStack {
                            MyImage(source: .asset(.logOutIcon))
                                .scaledToFit()
                                .frame(width: 24)
                            
                            Text("Log out")
                                .font(.appMedium18)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .frame(height: 54)
                        .padding(.horizontal)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FF7694").opacity(0.4),
                                    Color(hex: "#FF7694").opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .cornerRadius(8)
                    }
                    
                    VStack(spacing: 16) {
                        //MARK: Help and Support
                        Button {
                            
                        } label: {
                            Text("Help and Support")
                                .font(.appMedium16)
                                .underline()
                                .foregroundStyle(.white)
                        }
                        
                        //MARK: Help and Support
                        Button {
                            
                        } label: {
                            Text("Privacy Policy")
                                .font(.appMedium16)
                                .underline()
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var selection: Taps = .home
    SettingsView(selection: $selection)
}

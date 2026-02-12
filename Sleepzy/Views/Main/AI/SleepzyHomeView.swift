import SwiftUI
import FamilyControls
import Combine

// MARK: - Home View
struct SleepzyHomeView: View {
    @EnvironmentObject var appSelection: AppSelectionManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showNewBlock = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with moon and greeting
                        headerSection
                        
                        // Upcoming Section
                        upcomingSection
                        
                        // Digital Shield Card
                        digitalShieldCard
                        
                        // Manage Apps Button
                        manageAppsButton
                        
                        // Add New Block Button
                        addNewBlockButton
                        
                        // Sleep Stats
                        sleepStatsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                
                // Bottom Tab Bar
                VStack {
                    Spacer()
                    customTabBar
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewBlock) {
                NavigationStack {
                    NewBlockView { configuration in
                        viewModel.addBlock(configuration)
                    }
                    .environmentObject(appSelection)
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0B2E"),
                    Color(hex: "1A1B3E"),
                    Color(hex: "0A0B2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Stars effect
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.6)
                    )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.currentDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(viewModel.greeting)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Moon image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                
                // Craters
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 15, height: 15)
                    .offset(x: -10, y: -8)
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .offset(x: 12, y: 10)
                
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 10, height: 10)
                    .offset(x: 8, y: -15)
            }
        }
        .padding(.top, 50)
    }
    
    // MARK: - Upcoming Section
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            if viewModel.upcomingBlocks.isEmpty {
                Text("No upcoming blocks")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                ForEach(viewModel.upcomingBlocks) { block in
                    UpcomingBlockCard(block: block)
                }
            }
        }
    }
    
    // MARK: - Digital Shield Card
    private var digitalShieldCard: some View {
        HStack(spacing: 16) {
            // Status Indicator
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purple)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text("Digital Shield")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(viewModel.digitalShield.status)
                        .font(.system(size: 13))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(6)
                    
                    Text(viewModel.digitalShield.timing)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text("Apps to be Locked")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Active indicator
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Manage Apps Button
    private var manageAppsButton: some View {
        Button(action: {
            // Navigate to manage apps
        }) {
            HStack(spacing: 12) {
                // App Icons Row
                HStack(spacing: -8) {
                    ForEach(viewModel.lockedApps.prefix(5), id: \.self) { app in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: app.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "0A0B2E"), lineWidth: 2)
                            )
                    }
                    
                    if viewModel.lockedApps.count > 5 {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("...")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "0A0B2E"), lineWidth: 2)
                            )
                    }
                }
                
                Spacer()
                
                Text("Manage Apps")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Add New Block Button
    private var addNewBlockButton: some View {
        Button(action: {
            showNewBlock = true
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                
                Text("Limit App or Website")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
    
    // MARK: - Sleep Stats Section
    private var sleepStatsSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 14))
                .foregroundColor(.purple)
            
            Text("Sleep Last Night")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                
                Text(viewModel.sleepDuration)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: viewModel.selectedTab == .home,
                action: { viewModel.selectedTab = .home }
            )
            
            TabBarButton(
                icon: "music.note",
                title: "Sounds",
                isSelected: viewModel.selectedTab == .sounds,
                action: { viewModel.selectedTab = .sounds }
            )
            
            TabBarButton(
                icon: "list.bullet",
                title: "Sleep Log",
                isSelected: viewModel.selectedTab == .sleepLog,
                action: { viewModel.selectedTab = .sleepLog }
            )
            
            TabBarButton(
                icon: "bell.fill",
                title: "Alarm",
                isSelected: viewModel.selectedTab == .alarm,
                action: { viewModel.selectedTab = .alarm }
            )
            
            TabBarButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: viewModel.selectedTab == .settings,
                action: { viewModel.selectedTab = .settings }
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 34)
        .background(
            Rectangle()
                .fill(Color(hex: "0A0B2E"))
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        )
    }
}

// MARK: - Upcoming Block Card
struct UpcomingBlockCard: View {
    let block: UpcomingBlock
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(spacing: 4) {
                Text(block.timeRemaining)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.purple)
                
                Text("min")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: 60)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .frame(height: 40)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(block.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text("\(block.startTime) - \(block.endTime)")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - View Model
class HomeViewModel: ObservableObject {
    @Published var selectedTab: TabItem = .home
    @Published var upcomingBlocks: [UpcomingBlock] = []
    @Published var digitalShield = DigitalShield(
        status: "Starting in 15 min",
        timing: "Starts at 10:30 PM Starts at 10:30 PM"
    )
    @Published var lockedApps: [LockedApp] = [
        LockedApp(icon: "camera.fill"),
        LockedApp(icon: "message.fill"),
        LockedApp(icon: "music.note"),
        LockedApp(icon: "bell.fill"),
        LockedApp(icon: "photo.fill"),
        LockedApp(icon: "globe")
    ]
    @Published var sleepDuration = "7 Hr 15 min"
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    func addBlock(_ configuration: BlockConfiguration) {
        // Add logic to save block
        print("Block added: \(configuration.name)")
    }
}

// MARK: - Models
enum TabItem {
    case home, sounds, sleepLog, alarm, settings
}

struct UpcomingBlock: Identifiable {
    let id = UUID()
    let name: String
    let timeRemaining: String
    let startTime: String
    let endTime: String
}

struct DigitalShield {
    let status: String
    let timing: String
}

struct LockedApp: Identifiable, Hashable {
    let id = UUID()
    let icon: String
}

import SwiftUI
import FamilyControls
import Combine

// MARK: - New Block View (Main Screen)
struct NewBlockView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSelection: AppSelectionManager
    @StateObject private var viewModel = NewBlockViewModel()
    @State private var showAppPicker = false
    @State private var showBrakesSheet = false
    
    var onSave: (BlockConfiguration) -> Void
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with tabs
                    headerSection
                    
                    // Content based on selected tab
                    if viewModel.selectedTab == .schedule {
                        scheduleContent
                    } else {
                        timerContent
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            
            // Save Button (Fixed at bottom)
            VStack {
                Spacer()
                saveButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        }
        .familyActivityPicker(
            isPresented: $showAppPicker,
            selection: $appSelection.selection
        )
        .sheet(isPresented: $showBrakesSheet) {
            BrakesAllowedSheet(
                selectedBrake: $viewModel.selectedBrake,
                onSave: { showBrakesSheet = false }
            )
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0A0B2E"),
                Color(hex: "1A1B3E"),
                Color(hex: "0A0B2E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            Text("New Block")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Tab Selector
            HStack(spacing: 0) {
                TabButton(
                    title: "Schedule",
                    icon: "calendar",
                    isSelected: viewModel.selectedTab == .schedule,
                    action: { viewModel.selectedTab = .schedule }
                )
                
                TabButton(
                    title: "Timer",
                    icon: "timer",
                    isSelected: viewModel.selectedTab == .timer,
                    action: { viewModel.selectedTab = .timer }
                )
            }
            .frame(height: 50)
        }
    }
    
    // MARK: - Schedule Content
    private var scheduleContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Name Field
            nameField
            
            // From Time Picker
            timePickerSection(
                title: "FROM",
                hour: $viewModel.fromHour,
                minute: $viewModel.fromMinute,
                period: $viewModel.fromPeriod
            )
            
            // To Time Picker
            timePickerSection(
                title: "TO",
                hour: $viewModel.toHour,
                minute: $viewModel.toMinute,
                period: $viewModel.toPeriod
            )
            
            // Repeat On
            repeatOnSection
            
            // App Block List
            appBlockListSection
            
            // Brakes Allowed
            brakesAllowedSection
        }
    }
    
    // MARK: - Timer Content
    private var timerContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Name Field
            nameField
            
            // Duration Picker
            durationPickerSection
            
            // App Block List
            appBlockListSection
            
            // Brakes Allowed
            brakesAllowedSection
        }
    }
    
    // MARK: - Name Field
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NAME")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            HStack {
                TextField("", text: $viewModel.blockName)
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .placeholder(when: viewModel.blockName.isEmpty) {
                        Text("Weekends")
                            .foregroundColor(.white.opacity(0.4))
                    }
                
                Button(action: {
                    // Random name generator
                    viewModel.blockName = viewModel.generateRandomName()
                }) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Time Picker Section
    private func timePickerSection(
        title: String,
        hour: Binding<Int>,
        minute: Binding<Int>,
        period: Binding<Period>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            HStack(spacing: 12) {
                // Hour Picker
                TimeDigitPicker(value: hour, range: 1...12)
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.6))
                
                // Minute Picker
                TimeDigitPicker(value: minute, range: 0...59)
                
                Text(":")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.6))
                
                // Minute (Second digits)
                TimeDigitPicker(value: .constant(0), range: 0...5)
                
                TimeDigitPicker(value: .constant(0), range: 0...9)
                
                // AM/PM Picker
                VStack(spacing: 4) {
                    PeriodButton(
                        title: "AM",
                        isSelected: period.wrappedValue == .am,
                        action: { period.wrappedValue = .am }
                    )
                    PeriodButton(
                        title: "PM",
                        isSelected: period.wrappedValue == .pm,
                        action: { period.wrappedValue = .pm }
                    )
                }
            }
        }
    }
    
    // MARK: - Duration Picker Section (Timer)
    private var durationPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DURATION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            Button(action: {
                // Show duration picker
            }) {
                HStack {
                    Text("\(viewModel.durationMinutes) min")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Repeat On Section
    private var repeatOnSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REPEAT ON")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            HStack(spacing: 8) {
                ForEach(Weekday.allCases, id: \.self) { day in
                    DayButton(
                        day: day,
                        isSelected: viewModel.selectedDays.contains(day),
                        action: { viewModel.toggleDay(day) }
                    )
                }
            }
        }
    }
    
    // MARK: - App Block List Section
    private var appBlockListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APP BLOCK LIST")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            if !appSelection.selection.applicationTokens.isEmpty {
                // Show selected apps
                VStack(spacing: 8) {
                    ForEach(Array(appSelection.selection.applicationTokens.prefix(5).enumerated()), id: \.offset) { _, token in
                        HStack(spacing: 12) {
                            Label(token)
                                .labelStyle(.iconOnly)
                                .frame(width: 32, height: 32)
                            
                            Label(token)
                                .labelStyle(.titleOnly)
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                            
                            Spacer()
                        }
                    }
                    
                    if appSelection.selection.applicationTokens.count > 5 {
                        Button(action: { showAppPicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add More")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.purple)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            } else {
                Button(action: { showAppPicker = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Select apps to block")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
        }
    }
    
    // MARK: - Brakes Allowed Section
    private var brakesAllowedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BRAKES ALLOWED")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
            
            Button(action: { showBrakesSheet = true }) {
                HStack {
                    Image(systemName: viewModel.selectedBrake.icon)
                        .foregroundColor(.white)
                    
                    Text(viewModel.selectedBrake.title)
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            let config = viewModel.createConfiguration(
                selectedApps: appSelection.selection
            )
            onSave(config)
            dismiss()
        }) {
            Text("Save")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "0A0B2E"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(25)
        }
    }
}

// MARK: - Supporting Views

// Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.purple : Color.clear
            )
            .cornerRadius(10)
        }
    }
}

// Time Digit Picker
struct TimeDigitPicker: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        Menu {
            ForEach(Array(range), id: \.self) { num in
                Button(String(format: "%02d", num)) {
                    value = num
                }
            }
        } label: {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 50, height: 60)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// Period Button (AM/PM)
struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .purple : .white.opacity(0.5))
                .frame(width: 50, height: 28)
                .background(
                    isSelected ? Color.purple.opacity(0.2) : Color.clear
                )
                .cornerRadius(6)
        }
    }
}

// Day Button
struct DayButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    isSelected ? Color.purple : Color.white.opacity(0.05)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.purple : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Brakes Allowed Sheet
struct BrakesAllowedSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedBrake: BrakeType
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0A0B2E"),
                    Color(hex: "1A1B3E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                // Title
                Text("BRAKES ALLOWED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                
                // Options
                VStack(spacing: 0) {
                    ForEach(BrakeType.allCases, id: \.self) { brake in
                        BrakeOptionRow(
                            brake: brake,
                            isSelected: selectedBrake == brake,
                            action: {
                                selectedBrake = brake
                                onSave()
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.hidden)
    }
}

// Brake Option Row
struct BrakeOptionRow: View {
    let brake: BrakeType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: brake.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(brake.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(brake.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.purple : Color.white.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                Color.white.opacity(isSelected ? 0.08 : 0.03)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.purple.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .padding(.bottom, 8)
    }
}

// MARK: - View Model
class NewBlockViewModel: ObservableObject {
    @Published var selectedTab: BlockTab = .schedule
    @Published var blockName = ""
    
    // Schedule properties
    @Published var fromHour = 12
    @Published var fromMinute = 4
    @Published var fromPeriod: Period = .am
    
    @Published var toHour = 8
    @Published var toMinute = 2
    @Published var toPeriod: Period = .am
    
    @Published var selectedDays: Set<Weekday> = Set(Weekday.allCases)
    
    // Timer properties
    @Published var durationMinutes = 20
    
    // Brakes
    @Published var selectedBrake: BrakeType = .takeItEasy
    
    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    func generateRandomName() -> String {
        let names = ["Focus Time", "Deep Work", "Study Mode", "Relax Time", "Weekends", "Night Time", "Morning Routine"]
        return names.randomElement() ?? "New Block"
    }
    
    func createConfiguration(selectedApps: FamilyActivitySelection) -> BlockConfiguration {
        BlockConfiguration(
            name: blockName.isEmpty ? "New Block" : blockName,
            type: selectedTab,
            fromHour: fromHour,
            fromMinute: fromMinute,
            fromPeriod: fromPeriod,
            toHour: toHour,
            toMinute: toMinute,
            toPeriod: toPeriod,
            selectedDays: selectedDays,
            durationMinutes: durationMinutes,
            selectedApps: selectedApps,
            brakeType: selectedBrake
        )
    }
}

// MARK: - Models
enum BlockTab {
    case schedule, timer
}

enum Period: String {
    case am = "AM"
    case pm = "PM"
}

enum Weekday: String, CaseIterable {
    case m = "M"
    case t = "T"
    case w = "W"
    case th = "TH"
    case f = "F"
    case s = "S"
    case su = "SU"
}

enum BrakeType: String, CaseIterable {
    case takeItEasy = "Yes Take it easy"
    case makeItHarder = "Yes but make it harder"
    case hardcore = "No way, I am hardcore"
    
    var title: String {
        switch self {
        case .takeItEasy: return "Yes, take it easy"
        case .makeItHarder: return "Yes but make it harder"
        case .hardcore: return "No way, I am hardcore"
        }
    }
    
    var description: String {
        switch self {
        case .takeItEasy: return "You can bypass with one tap"
        case .makeItHarder: return "Requires solving a challenge"
        case .hardcore: return "No breaks until schedule ends"
        }
    }
    
    var icon: String {
        switch self {
        case .takeItEasy: return "hand.raised.slash"
        case .makeItHarder: return "shield.lefthalf.filled"
        case .hardcore: return "shield.fill"
        }
    }
}

struct BlockConfiguration: Codable {
    let name: String
    let type: BlockTab
    let fromHour: Int
    let fromMinute: Int
    let fromPeriod: Period
    let toHour: Int
    let toMinute: Int
    let toPeriod: Period
    let selectedDays: Set<Weekday>
    let durationMinutes: Int
    let selectedApps: FamilyActivitySelection
    let brakeType: BrakeType
}

// MARK: - Extensions
//extension View {
//    func placeholder<Content: View>(
//        when shouldShow: Bool,
//        alignment: Alignment = .leading,
//        @ViewBuilder placeholder: () -> Content
//    ) -> some View {
//        ZStack(alignment: alignment) {
//            placeholder().opacity(shouldShow ? 1 : 0)
//            self
//        }
//    }
//}

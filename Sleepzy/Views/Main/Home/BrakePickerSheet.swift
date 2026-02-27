import SwiftUI

struct BrakePickerSheet: View {
    
    @Binding var selected: BrakeLevel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Handle bar
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            Text("Brakes Allowed")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .kerning(1.2)
                .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                ForEach(BrakeLevel.allCases) { level in
                    BrakeLevelRow(level: level, isSelected: selected == level) {
                        selected = level
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            dismiss()
                        }
                    }
                    
                    if level != BrakeLevel.allCases.last {
                        Divider()
                            .background(AppTheme.separatorColor)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .padding(.horizontal, AppTheme.pagePadding)
            
            Spacer()
        }
        .background(Color(hex: "0A0E2A").ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

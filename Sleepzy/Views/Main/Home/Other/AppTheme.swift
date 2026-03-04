import SwiftUI

// MARK: - AppTheme

enum AppTheme {
    
    // MARK: Colors
    static let background        = Color(hex: "0A0E2A")
    static let cardBackground    = Color(hex: "111535").opacity(0.85)
    static let accent            = Color(hex: "5939A8").opacity(0.2)
    static let accentBright      = Color(hex: "9B6FD6")
    static let textPrimary       = Color.white
    static let textSecondary     = Color.white.opacity(0.6)
    static let pillBackground    = Color(hex: "1E2248")
    static let toggleOnTint      = Color(hex: "5B4FCC")
    static let tagBackground     = Color.white.opacity(0.1)
    static let separatorColor    = Color.white.opacity(0.08)
    
    // MARK: Gradients
    static let nightSkyGradient  = LinearGradient(
        colors: [Color(hex: "050A20"), Color(hex: "0D1540"), Color(hex: "1A2060")],
        startPoint: .top, endPoint: .bottom
    )
    
    // MARK: Corner Radii
    static let cardRadius:   CGFloat = 8
    static let fieldRadius:   CGFloat = 8
    static let buttonRadius: CGFloat = 14
    static let pillRadius:   CGFloat = 20
    
    // MARK: Spacing
    static let pagePadding:  CGFloat = 20
    static let cardPadding:  CGFloat = 16
    static let itemSpacing:  CGFloat = 12
}

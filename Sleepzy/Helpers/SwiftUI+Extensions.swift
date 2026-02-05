//
//  SwiftUI+Extensions.swift
//  DiwanV2
//
//  Created by Khaled on 28/02/2023.
//

import SwiftUI


public extension Image {
    static var placeholder = Image("empty_image")
    static var empty = Image("empty")
    static var userPlaceholder = Image("UserPlaceholder")
}

// MARK: - First Appear
public extension View {
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> ()
    
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}


// MARK: - Color HEX

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// // MARK: Corner Radius
// extension View {
//     func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//         clipShape( RoundedCorner(radius: radius, corners: corners) )
//     }
// }
// 
// struct RoundedCorner: Shape {
//     let radius: CGFloat
//     let corners: UIRectCorner
// 
//     init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
//         self.radius = radius
//         self.corners = corners
//     }
// 
//     func path(in rect: CGRect) -> Path {
//         let path = UIBezierPath(
//             roundedRect: rect,
//             byRoundingCorners: corners,
//             cornerRadii: CGSize(width: radius, height: radius)
//         )
//         return Path(path.cgPath)
//     }
// }

extension UIRectCorner {
    public static var topLeading: UIRectCorner {
        UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .topLeft : .topRight
    }

    public static var topTrailing: UIRectCorner {
        UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .topRight : .topLeft
    }

    public static var bottomLeading: UIRectCorner {
        UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .bottomLeft : .bottomRight
    }

    public static var bottomTrailing: UIRectCorner {
        UIApplication.shared.userInterfaceLayoutDirection == .leftToRight ? .bottomRight : .bottomLeft
    }

    public static var topCorners: UIRectCorner {
        [topLeft, topRight]
    }
    
    public static var bottomCorners: UIRectCorner {
        [bottomLeft, bottomRight]
    }

}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}
#endif


extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .hidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .hidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func hidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//
//  ButtonStyle.swift
//  OpaCouponUser
//
//  Created by SD on 04/12/2024.
//

import SwiftUI

public struct AppButtonStyle: ButtonStyle {
   
    var style: Style
    var shapeStyle: ShapeStyle = .capsule

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        let height = height
        configuration.label
            .foregroundStyle(isEnabled ? style.foregroundColor : style.disabledForegroundColor)
            .font(.appRegular(size: 20))
            .fontWeight(style.fontWeight)
            .padding(.vertical, 6)
            .padding(.horizontal, 16)
            .frame(
                minWidth: height,
                maxWidth: shapeStyle == .circle ? height : .infinity,
                minHeight: height,
                maxHeight: height
            )
            .background(isEnabled ? style.tintColor : style.disabledTintColor)
            .opacity(configuration.isPressed ? 0.5 : 1)
            // .saturation(isEnabled ? 1 : 0)
            .if (shapeStyle == .capsule) { content in
                content
                    .clipShape(Capsule())
            }
            .if (shapeStyle == .roundedRect) { content in
                content.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .if (shapeStyle == .circle) { content in
                content.clipShape(Circle())
            }
    }
    
    
    var height: CGFloat {
        return 54
    }
    
    var cornerRadius: CGFloat {
        return 8
    }
    
}

// MARK: Button Type
extension AppButtonStyle {
    public enum Style {
        case primary

        var tintColor: Color {
            switch self {
            case .primary:
                return .white
            }
        }

        var disabledTintColor: Color {
            switch self {
            case .primary:
                return .white.opacity(0.5)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary:
                return Color(hex: "#060A35")
            }
        }

        var disabledForegroundColor: Color {
            switch self {
            case .primary:
                return .white
            }
        }

        var fontWeight: Font.Weight {
            switch self {
            case .primary:
                return .regular
            }
        }
    }

}

// MARK: Shape Style
extension AppButtonStyle {
    public enum ShapeStyle {
        case capsule
        case roundedRect
        case circle
    }
}


extension Button {
    /// Changes the appearance of the button
    func style(_ style: AppButtonStyle.Style, shapeStyle: AppButtonStyle.ShapeStyle = .capsule) -> some View {
        self.buttonStyle(AppButtonStyle(style: style, shapeStyle: shapeStyle))
    }
}

// MARK: - Inits

extension Button where Label == MyImage {
    init(_ image: MyImage, action: @escaping () -> Void) {
        self.init(action: action) {
            image
        }
    }
}

extension Button where Label == Text {
    init(_ string: LocalizedStringKey, style: AppButtonStyle.Style = .primary, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(string)
        }
        
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            primaryRoundedRect
            Spacer()
        }
        .padding()
        .background(.white)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
    
    static var primaryRoundedRect: some View {
        Button(action: { }) {
            Text("Primary Rounded Button")
        }
        .style(.primary, shapeStyle: .roundedRect)
    }
}

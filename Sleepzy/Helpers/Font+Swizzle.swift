//
//  Font+Swizzle.swift
//  GBV
//
//  Created by Khaled on 12/08/2024.
//

import SwiftUI



extension Font {
    static func app(
        size: CGFloat,
        weight: Weight? = nil,
        family: AppFontFamily = .primary,
        relativeTo: Font.TextStyle = .body
    ) -> Font {
        let weight = weight ?? .regular
        return custom(weight.appFontName(family: family), size: size, relativeTo: relativeTo)
    }

    static func app(
        fixedSize: CGFloat,
        weight: Weight? = nil,
        family: AppFontFamily = .primary
    ) -> Font {
        let weight = weight ?? .regular
        return custom(weight.appFontName(family: family), fixedSize: fixedSize)
    }
    
    // Predefined Fonts
    
    // Extra bold font
    static var appExtrabold32: Font {
        app(size: 32, weight: .heavy, relativeTo: .title)
    }

    static var appExtrabold24: Font {
        app(size: 24, weight: .heavy, relativeTo: .title2)
    }
    
    static var appExtrabold20: Font {
        app(size: 20, weight: .heavy, relativeTo: .title3)
    }
    
    static var appExtrabold18: Font {
        app(size: 18, weight: .heavy, relativeTo: .headline)
    }
    
    static var appExtrabold16: Font {
        app(size: 16, weight: .heavy, relativeTo: .headline)
    }
    
    // Bold font
    static var appBold32: Font {
        app(size: 32, weight: .bold, relativeTo: .title)
    }

    static var appBold24: Font {
        app(size: 24, weight: .bold, relativeTo: .title2)
    }
    
    static var appBold20: Font {
        app(size: 20, weight: .bold, relativeTo: .title3)
    }
    
    static var appBold18: Font {
        app(size: 18, weight: .bold, relativeTo: .headline)
    }
    
    static var appBold16: Font {
        app(size: 16, weight: .bold, relativeTo: .headline)
    }
    
    static var appBold14: Font {
        app(size: 14, weight: .bold, relativeTo: .headline)
    }
    
    static var appBold12: Font {
        app(size: 12, weight: .bold, relativeTo: .headline)
    }
    
    static var appBold10: Font {
        app(size: 10, weight: .bold, relativeTo: .headline)
    }
    
    // Medium font
    static var appMedium20: Font {
        app(size: 20, weight: .medium, relativeTo: .headline)
    }
    
    static var appMedium18: Font {
        app(size: 18, weight: .medium, relativeTo: .headline)
    }

    static var appMedium16: Font {
        app(size: 16, weight: .medium, relativeTo: .callout)
    }
    
    static var appMedium14: Font {
        app(size: 14, weight: .medium, relativeTo: .subheadline)
    }
    
    static var appMedium12: Font {
        app(size: 12, weight: .medium, relativeTo: .caption)
    }
    
    static var appMedium11: Font {
        app(size: 11, weight: .medium, relativeTo: .caption2)
    }
    
    static var appMedium10: Font {
        app(size: 10, weight: .medium, relativeTo: .caption2)
    }
    
    // Regular font
    static var appRegular16: Font {
        app(size: 16, weight: .regular, relativeTo: .callout)
    }
    static var appRegular14: Font {
        app(size: 14, weight: .regular, relativeTo: .footnote)
    }
    static var appRegular12: Font {
        app(size: 12, weight: .regular, relativeTo: .caption)
    }

    static var appRegular10: Font {
        app(size: 10, weight: .regular, relativeTo: .caption2)
    }

    static func appRegular(size: CGFloat) -> Font {
        app(size: size, weight: .regular, relativeTo: .footnote)
    }
    
}


extension Font.Weight {
    func appFontName(family: AppFontFamily) -> String {
        switch family {
        case .primary:
            switch self {
            case .regular:
                return UIFont.FontWight.regular.rawValue
            case .medium:
                return UIFont.FontWight.medium.rawValue
            case .bold, .heavy, .black:
                return UIFont.FontWight.bold.rawValue
            default:
                return UIFont.FontWight.regular.rawValue
            }
        }
    }
}

enum AppFontFamily {
    case primary
//    case secondary
}

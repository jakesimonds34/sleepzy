//
//  UIFont+Swizzel.swift
//  SadaAlmustaqbal
//
//  Created by Khaled Khaldi on 11/1/19.
//  Copyright © 2019 SaDyKhAlEd. All rights reserved.
//

import UIKit

extension UIFont {
    
    static let mainFontFamily = "Poppins"
    
    enum FontWight: String {
        case light      = "Poppins-Light"
        case regular    = "Poppins-Regular"
        case medium     = "Poppins-Medium"
        case semiBold   = "Poppins-SemiBold"
        case bold       = "Poppins-Bold"
        case extraBold  = "Poppins-ExtraBold"
        
        // Second font
        case secondRegular    = "ElMessiri-Regular"
        case secondMedium     = "ElMessiri-Medium"
        case secondSemiBold   = "ElMessiri-SemiBold"
        case secondBold       = "ElMessiri-Bold"
    }
    
    static func mainFont(ofSize size: CGFloat, wight: UIFont.FontWight) -> UIFont {
        UIFont(name: wight.rawValue, size: size)!
    }
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    
    @objc class func myPreferredFont(forTextStyle style: String) -> UIFont {
        let defaultFont = myPreferredFont(forTextStyle: style)  // will not cause stack overflow - this is now the old, default UIFont.preferredFontForTextStyle
        let newDescriptor = defaultFont.fontDescriptor.withFamily(UIFont.mainFontFamily)
        return UIFont(descriptor: newDescriptor, size: defaultFont.pointSize)
    }
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        UIFont(name: UIFont.FontWight.regular.rawValue, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        UIFont(name: UIFont.FontWight.bold.rawValue, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        // UIFont(name: UIFont.FontWight.regularItalic.rawValue, size: size)!
        UIFont(name: UIFont.FontWight.regular.rawValue, size: size)!
    }
    
    @objc class func mySystemFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let fontName: FontWight
        
        switch weight {
        case .light:
            fontName = .light
        case .regular:
            fontName = .regular
        case .medium:
            fontName = .medium
        case .semibold:
            fontName = .semiBold
        case .bold:
            fontName = .bold
        case .heavy:
            fontName = .extraBold //.extraBold
        default:
            fontName = .regular
        }
        
        return UIFont(name: fontName.rawValue, size: size)!
        
    }
    
    @available(iOS 16.0, *)
    @objc class func mySystemFont(ofSize: CGFloat, weight: Weight, width: Width) -> UIFont {
        let font = mySystemFont(ofSize: ofSize, weight: weight)
        return font
    }

    
    /*
     print("fontAttribute: \(fontAttribute)")
     fontAttribute: CTFontUltraLightUsage
     fontAttribute: CTFontThinUsage
     fontAttribute: CTFontLightUsage
     fontAttribute: CTFontRegularUsage
     fontAttribute: CTFontMediumUsage
     fontAttribute: CTFontDemiUsage
     fontAttribute: CTFontBoldUsage
     fontAttribute: CTFontHeavyUsage
     fontAttribute: CTFontBlackUsage
     */
    
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
            self.init(myCoder: aDecoder)
            return
        }
        
        let fontName: FontWight
        
        switch fontAttribute {
        case "CTFontLightUsage":
            fontName = .light
            
        case "CTFontRegularUsage":
            fontName = .regular
            
        case "CTFontMediumUsage":
            fontName = .medium
            
        case "CTFontDemiUsage":
            fontName = .semiBold
            
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = .bold
            
        case "CTFontHeavyUsage":
            fontName = .extraBold //.extraBold
            
        default:
            fontName = .regular
        }
        
        self.init(name: fontName.rawValue, size: fontDescriptor.pointSize)!
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemPreferredFontMethod = class_getClassMethod(self, #selector(preferredFont(forTextStyle:))),
           let mySystemPreferredFontMethod = class_getClassMethod(self, #selector(myPreferredFont(forTextStyle:))) {
            method_exchangeImplementations(systemPreferredFontMethod, mySystemPreferredFontMethod)
        }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
           let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
           let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
           let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let systemFontWeightMethod = class_getClassMethod(self, #selector(systemFont(ofSize:weight:))),
           let mySystemFontWeightMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:weight:))) {
            method_exchangeImplementations(systemFontWeightMethod, mySystemFontWeightMethod)
        }
        
        if #available(iOS 16.0, *) {
            if let systemFontWeightWidthMethod = class_getClassMethod(self, #selector(systemFont(ofSize:weight:width:))),
               let mySystemFontWeightWidthMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:weight:width:))) {
                method_exchangeImplementations(systemFontWeightWidthMethod, mySystemFontWeightWidthMethod)
            }
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
           let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}

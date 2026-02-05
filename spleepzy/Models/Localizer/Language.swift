//
//  Language.swift
//  Localization102
//
//  Created by Khaled Khaldi on 4/10/19.
//  Copyright © 2019 Khaled Khaldi. All rights reserved.
//

import UIKit
import SwiftUI

private let appleLanguagesKey = "AppleLanguages"

enum Language: String {
    
    case `default` = "_"
    case english = "en"
    case arabic = "ar"
    
    var locale: Locale {
        // Locale(identifier: rawValue)
        switch self {
        case .default:
            return Locale(identifier: rawValue) // not real case
        case .english:
            return Locale(languageCode: .english)
        case .arabic:
            return Locale(languageCode: .arabic, script: .arabic, languageRegion: .libya)
        }
    }
    
    var semantic: UISemanticContentAttribute {
        switch self {
        case .default:
            return .unspecified
        case .arabic:
            return .forceRightToLeft
        default:
            return .forceLeftToRight
        }
    }
    
    var layoutDirection: LayoutDirection {
        switch self {
        case .default:
            return .leftToRight
        case .arabic:
            return .rightToLeft
        default:
            return .leftToRight
        }

    }
    
    var isRTL: Bool {
        switch self {
        case .arabic:
            return true
        default:
            return false
        }
    }
    
    var name: String {
        return Locale.current.localizedString(forIdentifier: self.rawValue) ?? self.rawValue
    }
    // var logo: String {
    //     switch self {
    //     case .default, .english:
    //         return "🇺🇸"
    //     case .arabic:
    //         return "🇸🇦"
    //     }
    // }
    
    var isolate: String {
        switch isRTL {
        case true:
            return "\u{2067}"
        case false:
            return "\u{2066}"
        }
    }
    
    static var current: Language {
        get {
            if let languagesCodes = UserDefaults.standard.stringArray(forKey: appleLanguagesKey),
                let language = languagesCodes.compactMap({ Language(rawValue: $0) }).first {
                return language
                
            } else {
                
                let preferredLanguage = NSLocale.preferredLanguages[0]
                let index = preferredLanguage.index(preferredLanguage.startIndex, offsetBy: 2)
                
                if let localization = Language(rawValue: preferredLanguage) {
                    return localization
                    
                } else if let localization = Language(rawValue: String(preferredLanguage[..<index])) {
                    return localization
                    
                } else {
                    return Language.english
                    
                }
                    
            }

        }
        
        set {
            guard current != newValue else { return }
            
            if newValue == .default {
                UserDefaults.standard.removeObject(forKey: appleLanguagesKey)
                UserDefaults.standard.synchronize()

            } else {
                // change language in the app
                // the language will be changed after restart
                UserDefaults.standard.set([newValue.rawValue], forKey: appleLanguagesKey)
                UserDefaults.standard.synchronize()
                
            }

            //Changes semantic to all views
            //this hack needs in case of languages with different semantics: leftToRight(en/uk) & rightToLeft(ar)
            UIView.appearance().semanticContentAttribute = Language.current.semantic
            UIView.appearance(whenContainedInInstancesOf: [UICollectionViewCell.self]).semanticContentAttribute = .unspecified

            //initialize the app from scratch
            //show initial view controller
            //so it seems like the is restarted
        }
    }

}

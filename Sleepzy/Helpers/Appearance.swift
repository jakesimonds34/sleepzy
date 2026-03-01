//
//  Appearance.swift
//  Snack
//
//  Created by Khaled Khaldi on 25/02/2022.
//

import UIKit
//import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import SwiftUI

private typealias Attributes = [NSAttributedString.Key: Any]

@MainActor
class Appearance {

    static var isDark: Bool {
        AppEnvironment.shared.colorScheme == .dark
    }
    
    static func configure() {
        UIFont.overrideInitialize()
//        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        
        // color scheme
        AppEnvironment.shared.colorScheme = .dark
        
        setupTabBarAppearance()
    }
    
    static func appearance(withBarColor barColor: UIColor? = nil,
                           titleColor: UIColor,
                           buttonsColor: UIColor,
                           backButtonImage: UIImage? = nil) -> UINavigationBarAppearance {
        // NavBar buttons
        let titleTextAttributes: Attributes = [
            .foregroundColor: titleColor,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        let largeTitleTextAttributes: Attributes = [
            .foregroundColor: titleColor,
            .font: UIFont.boldSystemFont(ofSize: 23)
        ]
        
        let backImage = backButtonImage?
            .imageFlippedForRightToLeftLayoutDirection()
    
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        
        if let barColor = barColor {
            navAppearance.backgroundColor = barColor
        }
        navAppearance.titleTextAttributes = titleTextAttributes
        navAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        
        navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        navAppearance.shadowImage = nil
        navAppearance.shadowColor = nil
        
        // New Bar button appearance code
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: buttonsColor
        ]
        //buttonAppearance.disabled.backgroundImage = nil
        navAppearance.buttonAppearance = buttonAppearance
        //navAppearance.doneButtonAppearance = buttonAppearance
        //navAppearance.backButtonAppearance = buttonAppearance
    
        return navAppearance
    }
    
    private static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if #unavailable(iOS 26) {
            appearance.backgroundColor = UIColor(hex: "#00012E")
            appearance.backgroundEffect = nil
        }
        
        updateTabBarItemAppearance(appearance: appearance.compactInlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: appearance.inlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: appearance.stackedLayoutAppearance)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        if #unavailable(iOS 26) {
            UITabBar.appearance().backgroundColor = UIColor(hex: "#00012E")
        }
    }
    
    private static func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
        let tintColor: UIColor = .white
        let unselectedItemTintColor: UIColor = .white.withAlphaComponent(0.5)
        
        appearance.selected.iconColor = tintColor
        appearance.normal.iconColor = unselectedItemTintColor
        // appearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        
        let selectedAttributes: Attributes = [
            .font: UIFont(name: UIFont.FontWight.regular.rawValue, size: 12)!,
            .foregroundColor: tintColor
        ]
        let attributes: Attributes = [
            .font: UIFont(name: UIFont.FontWight.regular.rawValue, size: 12)!,
            .foregroundColor: unselectedItemTintColor
        ]

        appearance.selected.titleTextAttributes = selectedAttributes
        appearance.normal.titleTextAttributes = attributes
    }
}

/// Set backButtonDisplayMode property to .minimal
extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

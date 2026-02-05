//
//  Appearance.swift
//  Snack
//
//  Created by Khaled Khaldi on 25/02/2022.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftUI

private typealias Attributes = [NSAttributedString.Key: Any]

@MainActor
class Appearance {

    static var isDark: Bool {
        AppEnvironment.shared.colorScheme == .dark
    }
    
    static func configure() {
        UIFont.overrideInitialize()
        IQKeyboardManager.shared.isEnabled = true
        
        // color scheme
        AppEnvironment.shared.colorScheme = .light
        
        setupTabBarAppearance()
//        UINavigationBar.appearance().standardAppearance = lightAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = lightAppearance
    }
    
    /*
    static let lightAppearance: UINavigationBarAppearance = appearance(
        withBarColor: isDark ? .black : .white,//.white,
        titleColor: .text,
        buttonsColor: .text,
        backButtonImage: UIImage(resource: isDark ? .nbBackDark : .nbBackLight).imageFlippedForRightToLeftLayoutDirection()
    )
    */
    // static let darkAppearance: UINavigationBarAppearance = appearance(
    //     //withBarColor: .accentColor,
    //     titleColor: .textColor,
    //     buttonsColor: .textColor,
    //     backButtonImage: UIImage(named: "NB Back")
    // )
    // 
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
        
        /*
         let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
         buttonAppearance.normal.titleTextAttributes = barBtnItemTitleEnabled
         buttonAppearance.disabled.titleTextAttributes = barBtnItemTitleDisabled
         
         let doneButtonAppearance = UIBarButtonItemAppearance(style: .done)
         doneButtonAppearance.normal.titleTextAttributes = barBtnItemTitleEnabled
         doneButtonAppearance.disabled.titleTextAttributes = barBtnItemTitleDisabled
         
         navAppearance.buttonAppearance = buttonAppearance
         navAppearance.doneButtonAppearance = doneButtonAppearance
         */
        
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
        
         // // Bar Button Image Color
         // let barButton = UIBarButtonItem.appearance(
         //     whenContainedInInstancesOf: [navigationBarType.self]
         // )
         // barButton.tintColor = buttonsColor
    
    }
    
    /*
    private static func setupAppearanceForAlertController() {
        let view = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        view.tintColor = .main
    }
    */
    
    private static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    /*
    private static func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        //tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // tabBarAppearance.backgroundColor = .accent
        // tabBarAppearance.selectionIndicatorTintColor = .white
        
        
        // let image = UIImage
        //     .tbBackground
        //     .resizableImage(
        //         withCapInsets: UIEdgeInsets(top: 44, left: 44, bottom: 1, right: 44),
        //         resizingMode: .stretch
        //     )
        // tabBarAppearance.backgroundImage = image
        tabBarAppearance.backgroundColor = UIColor.tabBarBG
        tabBarAppearance.shadowImage = UIImage(resource: .empty)
        
        updateTabBarItemAppearance(appearance: tabBarAppearance.compactInlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: tabBarAppearance.inlineLayoutAppearance)
        updateTabBarItemAppearance(appearance: tabBarAppearance.stackedLayoutAppearance)
        
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    */
    
    /*
    private static func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
        let tintColor: UIColor = .main
        let unselectedItemTintColor: UIColor = .black
        
        appearance.selected.iconColor = tintColor
        appearance.normal.iconColor = unselectedItemTintColor
        // appearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
        
        let selectedAttributes: Attributes = [
            .font: UIFont(name: UIFont.FontWight.medium.rawValue, size: 12)!,
            .foregroundColor: tintColor
        ]
        let attributes: Attributes = [
            .font: UIFont(name: UIFont.FontWight.medium.rawValue, size: 12)!,
            .foregroundColor: unselectedItemTintColor
        ]

        appearance.selected.titleTextAttributes = selectedAttributes
        appearance.normal.titleTextAttributes = attributes
        
    }
    */
}

/// Set backButtonDisplayMode property to .minimal
extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
    
}

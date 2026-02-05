//
//  SwiftMessages+Extensions.swift
//  DiwanV2
//
//  Created by Khaled on 05/09/2024.
//  Copyright © 2024 Master Team. All rights reserved.
//

import SwiftUI
import SwiftMessages

final class Alerts {
    @MainActor 
    static func show(title: String? = nil, body: String, theme: Theme) {
        // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
        // files in the main bundle first, so you can easily copy them into your project and make changes.
        let view = MessageView.viewFromNib(layout: .messageView)
        
        // Add a drop shadow.
        view.configureDropShadow()
        view.configureContent(
            title: title,
            body: body,
            iconImage: nil,
            iconText: nil,
            buttonImage: nil,
            buttonTitle: nil,
            buttonTapHandler: nil
        )
        
        // Theme message elements with the warning style.
        view.configureTheme(theme, includeHaptic: true)

        view.button?.isHidden = true
        view.buttonTapHandler = nil
        
        // Show the message.
        SwiftMessages.show(view: view)

    }
}

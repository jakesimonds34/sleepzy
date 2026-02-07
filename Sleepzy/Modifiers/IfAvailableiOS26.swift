//
//  IfAvailableiOS26.swift
//  AL-FATEH MOSQUE
//
//  Created by Saadi Dalloul on 22/11/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func safeTabBarMinimize() -> some View {
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}

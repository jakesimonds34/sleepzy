//
//  RoundedView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 08/02/2026.
//

import SwiftUI

extension View {
    func roundedView() -> some View {
        self
            .padding(.horizontal)
            .frame(height: 54)
            .background(.white.opacity(0.05))
            .cornerRadius(8)
            .padding(.vertical, 8)
            .font(.appMedium18)
            .tint(Color(hex: "5939A8"))
    }
}

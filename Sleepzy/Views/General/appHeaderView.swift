//
//  appHeaderView.swift
//  AL-FATEH MOSQUE
//
//  Created by Saadi Dalloul on 19/11/2025.
//

import SwiftUI

struct AppHeaderView: View {
    @Environment(\.dismiss) private var dismiss
    let title: LocalizedStringKey
    let subTitle: LocalizedStringKey
    let isBack: Bool
    var paddingTop: Double
    
    init(title: LocalizedStringKey, subTitle: LocalizedStringKey, isBack: Bool = false, paddingTop: Double = 68) {
        self.title = title
        self.subTitle = subTitle
        self.isBack = isBack
        self.paddingTop = paddingTop
    }
    
    var body: some View {
        HStack(spacing: 13) {
            HStack(spacing: 16) {
                if isBack {
                    Button {
                        dismiss()
                    } label: {
                        MyImage(source: .system("arrow.backward"))
                            .scaledToFit()
                            .frame(width: 18)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.appRegular(size: 34))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white,
                                         Color(hex: "#988AE1"),
                                         Color(hex: "#988AE1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(subTitle)
                        .font(.appRegular(size: 17))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .padding(.top, paddingTop)
        .foregroundStyle(.white)
    }
}

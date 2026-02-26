//
//  SleepScoreView.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 26/02/2026.
//

import SwiftUI

// MARK: - Sleep Score View
struct SleepScoreView: View {
    var title: String
    let image: ImageResource
    let heightImage: CGFloat
    let issues: [RowItem]
    let footerNote: String
    
    var body: some View {
        VStack(spacing: 24) {
            AppHeaderView(
                title: title,
                subTitle: "",
                isBack: false,
                paddingTop: 16
            )
            .padding(.horizontal)
            
            // Gauge
            MyImage(source: .asset(image))
                .scaledToFit()
                .frame(height: heightImage)
            
            // Issues List
            VStack(spacing: 12) {
                ForEach(issues, id: \.title) { item in
                    RowItemView(item: item, isSelected: false, isCheck: false)
                }
            }
            .padding(.horizontal)
            
            // Footer Note
            Text(footerNote)
                .font(.appRegular(size: 14))
                .foregroundStyle(Color(hex: "#D3D2E2"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 16)
    }
}

#Preview {
    SleepScoreView(
        title: "",
        image: .scoreProgress,
        heightImage: 172,
        issues: [RowItem(title: "Late-night Scrolling")],
        footerNote: "Y"
    )
}

//
//  ErrorField.swift
//  DiwanV2
//
//  Created by Khaled on 27/07/2024.
//  Copyright © 2024 Master Team. All rights reserved.
//

import SwiftUI

struct ErrorField: View {
    let error: LocalizedStringKey?
    var body: some View {
        if let error {
            Text(error)
                .font(.appMedium16)
                .foregroundColor(Color(.red))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ErrorField(error: "Error Sample 🙃")
}

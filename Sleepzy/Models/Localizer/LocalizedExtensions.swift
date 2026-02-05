//
//  LocalizedExtensions.swift
//  pplus4
//
//  Created by Khaled on 28/08/2023.
//

import SwiftUI

extension String {
    var xcLocalized: String {
        String(
            localized: LocalizedStringResource(
                .init(self),
                locale: Language.current.locale
            )
        )
    }

    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized( _ args: CVarArg...) -> String {
        // return String.localizedStringWithFormat(self.localized, args)
        return String(format: self.localized, locale: Language.current.locale, arguments: args)
    }
    
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
}

extension Bool {
    var localized: String {
        NSLocalizedString("\(self)", comment: "")
    }
}

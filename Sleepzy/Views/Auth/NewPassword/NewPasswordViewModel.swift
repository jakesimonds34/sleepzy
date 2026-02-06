//
//  NewPasswordViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import Combine

class NewPasswordViewModel: ObservableObject {
    
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
}

//
//  SignupViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import Combine

class SignupViewModel: ObservableObject {
    
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var showOnboarding: Bool = false
    
}


//
//  LoginViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import Combine

class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var showSignup: Bool = false
    
}

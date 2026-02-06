//
//  EnterCodeViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 06/02/2026.
//

import Combine

class EnterCodeViewModel: ObservableObject {
    
    @Published var email: String = ""
    
    @Published var verificationCode = ""
    @Published var otpLength = 6
    
    @Published var showNewPassword: Bool = false
    
}

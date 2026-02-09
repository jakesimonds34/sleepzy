//
//  SupabaseService.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 09/02/2026.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://bpjaxyfiiwzewdsvonjt.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwamF4eWZpaXd6ZXdkc3Zvbmp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1ODUxNzQsImV4cCI6MjA4NjE2MTE3NH0.7KLUifIM0mquIba6kZxasymCMogvwQzRd89v2LOtMxg"
        )
    }
}

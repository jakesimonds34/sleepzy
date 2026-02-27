//
//  HomeViewModel.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 07/02/2026.
//

import Foundation
import FamilyControls
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var timeOfDayGreeting: String = ""
    @Published var todayDateString: String   = ""
    
    private let store: BlockStore
    private var cancellables = Set<AnyCancellable>()
    
    var digitalShield: DigitalShield? { store.digitalShield }
    var sleepDuration: String         { store.sleepDuration  }
    
    init(store: BlockStore = .shared) {
        self.store = store
        refreshGreeting()
    }
    
    func refreshGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  timeOfDayGreeting = "Good morning"
        case 12..<17: timeOfDayGreeting = "Good afternoon"
        default:      timeOfDayGreeting = "Good evening"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        todayDateString = formatter.string(from: Date()).uppercased()
    }
    
    func toggleShield() {
        store.toggleShield()
    }
}

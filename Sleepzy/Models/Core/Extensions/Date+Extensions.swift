//
//  Date+Extensions.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 12/02/2026.
//

import SwiftUI

// MARK: - Date Extensions
//extension Date {
//    func timeAgo() -> String {
//        let calendar = Calendar.current
//        let now = Date()
//        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)
//        
//        if let weeks = components.weekOfYear, weeks > 0 {
//            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
//        }
//        
//        if let days = components.day, days > 0 {
//            return days == 1 ? "Yesterday" : "\(days) days ago"
//        }
//        
//        if let hours = components.hour, hours > 0 {
//            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
//        }
//        
//        if let minutes = components.minute, minutes > 0 {
//            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
//        }
//        
//        return "Just now"
//    }
//}

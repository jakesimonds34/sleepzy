//
//  LocalData.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 11/02/2026.
//

import Foundation

struct LocalData {
    
    struct Goals {
        static let items: [RowItem] = [
            RowItem(icon: .sleepIcon, title: "Fall asleep faster"),
            RowItem(icon: .pillowIcon, title: "Stay asleep longer"),
            RowItem(icon: .wakeUpIcon, title: "Wake up refreshed"),
            RowItem(icon: .timeIcon, title: "Reduce screen time")
        ]
    }
    
    struct Distractions {
        static let items: [RowItem] = [
            RowItem(icon: .socialMediaIcon, title: "Social media scrolling"),
            RowItem(icon: .laptopIcon, title: "Late night work"),
            RowItem(icon: .brainIcon, title: "Overactive thinking"),
            RowItem(icon: .hearIcon, title: "Environmental noises ")
        ]
    }
    
    struct Ages {
        static let items: [RowItem] = [
            RowItem(title: "10-17"),
            RowItem(title: "18-24"),
            RowItem(title: "25-34"),
            RowItem(title: "35-44"),
            RowItem(title: "45+")
        ]
    }
    
    struct Gender {
        static let items: [RowItem] = [
            RowItem(title: "Female"),
            RowItem(title: "Male"),
            RowItem(title: "Other"),
            RowItem(title: "Prefer not to say")
        ]
    }
    
    struct StayAsleep {
        static let items: [RowItem] = [
            RowItem(title: "Not at all difficult"),
            RowItem(title: "A little difficult"),
            RowItem(title: "Somewhat difficult"),
            RowItem(title: "Difficult"),
            RowItem(title: "Very difficult")
        ]
    }
    
    struct EarlyWakeupRating {
        static let items: [RowItem] = [
            RowItem(title: "None"),
            RowItem(title: "Mild"),
            RowItem(title: "Moderate"),
            RowItem(title: "Severe"),
            RowItem(title: "Very Severe")
        ]
    }
    
    struct DailyFunction {
        static let items: [RowItem] = [
            RowItem(title: "Not at all"),
            RowItem(title: "Barely"),
            RowItem(title: "Somewhat"),
            RowItem(title: "Much"),
            RowItem(title: "Very much interfering")
        ]
    }
    
    struct DistractingApps {
        static let items: [RowItem] = [
            RowItem(title: "Instagram"),
            RowItem(title: "Tiktok"),
            RowItem(title: "Youtube"),
            RowItem(title: "Facebook"),
            RowItem(title: "Messenger")
        ]
    }
}

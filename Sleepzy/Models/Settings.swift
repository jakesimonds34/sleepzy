//
//  Settings.swift
//  Sleepzy
//
//  Created by Saadi Dalloul on 27/02/2026.
//

import UIKit

struct Settings: Codable {
    
    var currentUser: Profile? {
        didSet {
            NotificationCenter.default.post(name: .userInfoChanged, object: currentUser)
            save()
        }
    }
    
    // MARK: - Computed Values
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    mutating func resetUserSettings() {
        currentUser = nil
        save()
    }
    
    
    
    // MARK: - Coding
    enum CodingKeys: String, CodingKey {
        case currentUser
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentUser       = try? container.decodeIfPresent(Profile.self, forKey: .currentUser)
    }
    
    
    // MARK: - Private
    
    private static let UserDefaultsKey = "com.saadi.settings"
    
    static var shared: Settings = {
        struct Static {
            static var instance: Settings? = nil
        }
        
        if Static.instance == nil {
            
            if let data = UserDefaults.standard.object(forKey: UserDefaultsKey) as? Data {
                let decoder = PropertyListDecoder()
                do {
                    Static.instance = try decoder.decode(Settings.self, from: data)
                } catch {
                    Static.instance = Settings()
                    print("Error: \(error)")
                }
                
            } else {
                Static.instance = Settings()
            }
            
        }
        
        return Static.instance!
    }()
    
    private init() {
        
    }
    
    /*
     // You have to call - Settings.shared.save()
     // @ applicationDidEnterBackground & applicationWillTerminate
     */
    public func save() {
        do {
            let defaults = UserDefaults.standard
            defaults.set(try PropertyListEncoder().encode(self), forKey: Settings.UserDefaultsKey)
            defaults.synchronize()
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    
}


extension Notification.Name {
    static let userInfoChanged = Notification.Name("userInfoChanged")
}

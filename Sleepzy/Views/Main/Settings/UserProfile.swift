import Foundation
import Combine

// MARK: - UserProfile model + persistence

struct UserProfile: Codable {
    var firstName: String = Settings.shared.currentUser?.fullName.components(separatedBy: " ").first ?? ""
    var lastName:  String = Settings.shared.currentUser?.fullName.components(separatedBy: " ").last ?? ""
    var sleepGoal: String = Settings.shared.currentUser?.goal ?? ""
    var bedHour:   Double = Settings.shared.currentUser?.bedHour ?? 22
    var wakeHour:  Double = Settings.shared.currentUser?.wakeHour ?? 7
    var windDownNotification: Bool = true
    var shieldNotification:   Bool = true
    var appleHealthSync:      Bool = true

    var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return f + l
    }
    var fullName: String { "\(firstName) \(lastName)" }
}

@MainActor
final class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore()
    private let key = "userProfile_v1"

    @Published var profile: UserProfile = UserProfile()

    private init() { load() }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return }
        profile = decoded
    }
}

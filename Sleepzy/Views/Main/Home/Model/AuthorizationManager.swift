import FamilyControls
import Combine
import os.log
import Foundation

@MainActor
final class AuthorizationManager: ObservableObject {
    
    static let shared = AuthorizationManager()
    private let logger = Logger(subsystem: "com.timescreen.app", category: "Auth")
    
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var authError: Error?
    
    private let center = AuthorizationCenter.shared
    
    private init() {
        isAuthorized = center.authorizationStatus == .approved
    }
    
    func requestAuthorization() async {
        guard center.authorizationStatus != .approved else {
            isAuthorized = true
            return
        }
        do {
            try await center.requestAuthorization(for: .individual)
            isAuthorized = center.authorizationStatus == .approved
            logger.info("Family Controls authorization granted.")
        } catch {
            authError = error
            isAuthorized = false
            logger.error("Authorization failed: \(error.localizedDescription)")
        }
    }
}

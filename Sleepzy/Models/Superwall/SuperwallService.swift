//
//  SuperwallService.swift
//  Sleepzy
//

import Foundation
import SuperwallKit

// MARK: - SuperwallService
final class SuperwallService {

    static let apiKey = "pk_NjB6bcZcDrDQRHdseA__-"

    // اسم الـ trigger — يمكن تغييره من Superwall dashboard
    static let onboardingPlacement = "campaign_trigger"

    // MARK: - Configure (يُستدعى عند launch)
    static func configure() {
        Superwall.configure(apiKey: apiKey)
    }

    // MARK: - Show Paywall بعد Onboarding
    // onPresent   → الـ paywall ظهر
    // onDismiss   → المستخدم أغلق (اشترى أو لا)
    @MainActor
    static func presentPaywall(
        onSkip:    @escaping () -> Void = {},
        onPurchase: @escaping () -> Void = {}
    ) {
        Superwall.shared.register(placement: onboardingPlacement) {
            // هذا الـ block يُنفَّذ فقط إذا كان المستخدم مشتركاً بالفعل
            // أو إذا أغلق الـ paywall بعد الشراء
            onPurchase()
        }
    }
}

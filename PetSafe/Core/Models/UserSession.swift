import Foundation
internal import Combine
import SwiftUI

// MARK: - User Session
/// Manages user authentication and premium status
@MainActor
class UserSession: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var isPremiumUser: Bool = false
    @Published var userEmail: String = ""
    @Published var userId: String = ""
    @Published var isTestAccount: Bool = false

    // MARK: - Singleton
    static let shared = UserSession()

    private init() {
        loadSession()
    }

    // MARK: - Test Accounts
    private let testAccounts: [TestAccount] = [
        TestAccount(
            email: "test@petsafe.com",
            password: "test123",
            isPremium: true,
            displayName: "Test User (Premium)"
        ),
        TestAccount(
            email: "premium@petsafe.com",
            password: "premium",
            isPremium: true,
            displayName: "Premium Tester"
        ),
        TestAccount(
            email: "free@petsafe.com",
            password: "free",
            isPremium: false,
            displayName: "Free User"
        )
    ]

    // MARK: - Authentication
    func login(email: String, password: String) -> Bool {
        // Check if it's a test account
        if let testAccount = testAccounts.first(where: {
            $0.email.lowercased() == email.lowercased() && $0.password == password
        }) {
            isAuthenticated = true
            isPremiumUser = testAccount.isPremium
            userEmail = testAccount.email
            userId = testAccount.email
            isTestAccount = true

            saveSession()
            return true
        }

        // For any other email/password, authenticate but free tier
        if !email.isEmpty && !password.isEmpty {
            isAuthenticated = true
            isPremiumUser = false
            userEmail = email
            userId = email
            isTestAccount = false

            saveSession()
            return true
        }

        return false
    }

    func loginWithApple(userId: String, email: String?) {
        isAuthenticated = true
        isPremiumUser = false // Default to free
        self.userId = userId
        self.userEmail = email ?? "apple_\(userId)"
        isTestAccount = false

        saveSession()
    }

    func loginAsTestPremium() {
        isAuthenticated = true
        isPremiumUser = true
        userEmail = "test@petsafe.com"
        userId = "test_premium_user"
        isTestAccount = true

        saveSession()
    }

    func logout() {
        isAuthenticated = false
        isPremiumUser = false
        userEmail = ""
        userId = ""
        isTestAccount = false

        clearSession()
    }

    func upgradeToPremium() {
        isPremiumUser = true
        saveSession()
    }

    func downgradToFree() {
        isPremiumUser = false
        saveSession()
    }

    // MARK: - Persistence
    private func saveSession() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(isTestAccount, forKey: "isTestAccount")
    }

    private func loadSession() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        isTestAccount = UserDefaults.standard.bool(forKey: "isTestAccount")
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "isPremiumUser")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "isTestAccount")
    }
}

// MARK: - Test Account Model
struct TestAccount {
    let email: String
    let password: String
    let isPremium: Bool
    let displayName: String
}

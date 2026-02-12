import XCTest

/// Page Object for Settings Screen
struct SettingsPage {
    let app: XCUIApplication

    // MARK: - Elements
    var settingsTitle: XCUIElement {
        app.navigationBars["Settings"]
    }

    var closeButton: XCUIElement {
        app.buttons["close_button"]
    }

    // Profile Section
    var dogNameLabel: XCUIElement {
        app.staticTexts["dog_name"]
    }

    var editProfileButton: XCUIElement {
        app.buttons["Edit Profile"]
    }

    // Subscription Section
    var subscriptionStatusLabel: XCUIElement {
        app.staticTexts["subscription_status"]
    }

    var managePremiumButton: XCUIElement {
        app.buttons["Manage Premium"]
    }

    var upgradeToPremiumButton: XCUIElement {
        app.buttons["Upgrade to Premium"]
    }

    // Notifications Section
    var notificationsToggle: XCUIElement {
        app.switches["notifications_toggle"]
    }

    var dailyRemindersToggle: XCUIElement {
        app.switches["daily_reminders_toggle"]
    }

    // Data & Privacy Section
    var exportDataButton: XCUIElement {
        app.buttons["Export My Data"]
    }

    var deleteAccountButton: XCUIElement {
        app.buttons["Delete Account"]
    }

    // About Section
    var privacyPolicyButton: XCUIElement {
        app.buttons["Privacy Policy"]
    }

    var termsOfServiceButton: XCUIElement {
        app.buttons["Terms of Service"]
    }

    var versionLabel: XCUIElement {
        app.staticTexts["version_label"]
    }

    // Account Section
    var logoutButton: XCUIElement {
        app.buttons["Log Out"]
    }

    var logoutConfirmButton: XCUIElement {
        app.buttons["confirm_logout_button"].firstMatch
    }

    // MARK: - Actions
    func tapClose() {
        closeButton.tap()
    }

    func tapEditProfile() {
        editProfileButton.tap()
    }

    func tapManagePremium() {
        managePremiumButton.tap()
    }

    func tapUpgradeToPremium() {
        upgradeToPremiumButton.tap()
    }

    func toggleNotifications() {
        notificationsToggle.tap()
    }

    func toggleDailyReminders() {
        dailyRemindersToggle.tap()
    }

    func tapExportData() {
        exportDataButton.tap()
    }

    func tapPrivacyPolicy() {
        privacyPolicyButton.tap()
    }

    func tapTermsOfService() {
        termsOfServiceButton.tap()
    }

    func tapLogout() {
        logoutButton.tap()
    }

    func confirmLogout() {
        logoutConfirmButton.tap()
    }

    func logout() {
        tapLogout()
        confirmLogout()
    }

    // MARK: - Verifications
    func verifySettingsDisplayed() -> Bool {
        return settingsTitle.waitForExistence(timeout: 5)
    }

    func verifyPremiumStatus() -> Bool {
        return subscriptionStatusLabel.exists &&
               managePremiumButton.exists
    }

    func verifyFreeStatus() -> Bool {
        return upgradeToPremiumButton.exists
    }

    func verifyDogProfileDisplayed() -> Bool {
        return dogNameLabel.exists &&
               editProfileButton.exists
    }
}

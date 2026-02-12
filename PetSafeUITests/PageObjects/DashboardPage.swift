import XCTest

/// Page Object for Dashboard Screen
struct DashboardPage {
    let app: XCUIApplication

    // MARK: - Tab Bar Elements
    var homeTab: XCUIElement {
        app.buttons["HomeTab"]
    }

    var scanTab: XCUIElement {
        app.buttons["ScanTab"]
    }

    var logTab: XCUIElement {
        app.buttons["LogTab"]
    }

    var settingsButton: XCUIElement {
        app.buttons["Settings"]
    }

    // MARK: - Home Tab Elements
    var welcomeText: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Welcome'")).firstMatch
    }

    var copperTrackerCard: XCUIElement {
        app.otherElements["copper_tracker_card"]
    }

    var todaysIntakeLabel: XCUIElement {
        app.staticTexts["todays_intake_label"]
    }

    var recommendedLimitLabel: XCUIElement {
        app.staticTexts["recommended_limit_label"]
    }

    var quickScanButton: XCUIElement {
        app.buttons["Quick Scan"]
    }

    var achievementsCard: XCUIElement {
        app.buttons["Achievements"]
    }

    var premiumBadge: XCUIElement {
        app.images["premium_badge"]
    }

    // MARK: - Actions
    func tapHomeTab() {
        homeTab.tap()
    }

    func tapScanTab() {
        scanTab.tap()
    }

    func tapLogTab() {
        logTab.tap()
    }

    func tapSettings() {
        settingsButton.tap()
    }

    func tapQuickScan() {
        quickScanButton.tap()
    }

    func tapAchievements() {
        achievementsCard.tap()
    }

    // MARK: - Verifications
    func verifyDashboardDisplayed() -> Bool {
        return homeTab.waitForExistence(timeout: 10) &&
               scanTab.exists &&
               logTab.exists
    }

    func verifyHomeTabActive() -> Bool {
        return welcomeText.exists &&
               copperTrackerCard.exists
    }

    func verifyPremiumStatus() -> Bool {
        return premiumBadge.exists
    }

    func verifyCopperTrackerDisplayed() -> Bool {
        return copperTrackerCard.exists &&
               todaysIntakeLabel.exists &&
               recommendedLimitLabel.exists
    }
}

import XCTest

/// Page Object for Subscription Paywall Screen
struct PaywallPage {
    let app: XCUIApplication

    // MARK: - Elements
    var closeButton: XCUIElement {
        app.buttons["Close"]
    }

    var premiumTitle: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Premium'")).firstMatch
    }

    var monthlyPlanButton: XCUIElement {
        app.buttons["monthly_plan"]
    }

    var yearlyPlanButton: XCUIElement {
        app.buttons["yearly_plan"]
    }

    var monthlyPriceLabel: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$4.99'")).firstMatch
    }

    var yearlyPriceLabel: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$39.99'")).firstMatch
    }

    var subscribeButton: XCUIElement {
        app.buttons["Subscribe Now"]
    }

    var restorePurchasesButton: XCUIElement {
        app.buttons["Restore Purchases"]
    }

    var termsLink: XCUIElement {
        app.buttons["Terms of Service"]
    }

    var privacyLink: XCUIElement {
        app.buttons["Privacy Policy"]
    }

    // Features List
    var unlimitedScansFeature: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Unlimited'")).firstMatch
    }

    var advancedAnalyticsFeature: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Analytics'")).firstMatch
    }

    var prioritySupportFeature: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Support'")).firstMatch
    }

    // Purchase Confirmation
    var purchaseSuccessMessage: XCUIElement {
        app.staticTexts["You're all set"]
    }

    var purchaseFailureMessage: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'failed' OR label CONTAINS 'error'")).firstMatch
    }

    // MARK: - Actions
    func tapClose() {
        closeButton.tap()
    }

    func selectMonthlyPlan() {
        monthlyPlanButton.tap()
    }

    func selectYearlyPlan() {
        yearlyPlanButton.tap()
    }

    func tapSubscribe() {
        subscribeButton.tap()
    }

    func tapRestorePurchases() {
        restorePurchasesButton.tap()
    }

    func subscribeTo(plan: String) {
        if plan.lowercased() == "monthly" {
            selectMonthlyPlan()
        } else {
            selectYearlyPlan()
        }
        tapSubscribe()
    }

    // MARK: - Verifications
    func verifyPaywallDisplayed() -> Bool {
        return premiumTitle.waitForExistence(timeout: 5) &&
               (monthlyPlanButton.exists || yearlyPlanButton.exists)
    }

    func verifyPricingDisplayed() -> Bool {
        return monthlyPriceLabel.exists &&
               yearlyPriceLabel.exists
    }

    func verifyFeaturesDisplayed() -> Bool {
        return unlimitedScansFeature.exists ||
               advancedAnalyticsFeature.exists ||
               prioritySupportFeature.exists
    }

    func verifyPurchaseSuccess() -> Bool {
        return purchaseSuccessMessage.waitForExistence(timeout: 10)
    }

    func verifyPurchaseFailure() -> Bool {
        return purchaseFailureMessage.waitForExistence(timeout: 10)
    }
}

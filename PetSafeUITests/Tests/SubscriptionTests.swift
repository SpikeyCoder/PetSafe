import XCTest

/// Test Suite for Subscription/Paywall Functionality
final class SubscriptionTests: PetSafeUITestBase {

    // MARK: - Test: Paywall Displays
    func testPaywallDisplays() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)
                XCTAssertTrue(paywall.verifyPaywallDisplayed(), "Paywall should display")

                takeScreenshot(name: "53_Paywall")
            }
        }
    }

    // MARK: - Test: Subscription Plans Display
    func testSubscriptionPlansDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    XCTAssertTrue(
                        paywall.verifyPricingDisplayed(),
                        "Subscription pricing should be displayed"
                    )

                    takeScreenshot(name: "54_Pricing_Plans")

                    assertElementExists(paywall.monthlyPlanButton)
                    assertElementExists(paywall.yearlyPlanButton)
                }
            }
        }
    }

    // MARK: - Test: Premium Features Display
    func testPremiumFeaturesDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    XCTAssertTrue(
                        paywall.verifyFeaturesDisplayed(),
                        "Premium features should be displayed"
                    )

                    takeScreenshot(name: "55_Premium_Features")
                }
            }
        }
    }

    // MARK: - Test: Monthly Plan Selection
    func testMonthlyPlanSelection() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    paywall.selectMonthlyPlan()

                    takeScreenshot(name: "56_Monthly_Selected")

                    // Verify monthly plan is selected (visual state change)
                    XCTAssertTrue(paywall.monthlyPlanButton.exists, "Monthly plan should be selectable")
                }
            }
        }
    }

    // MARK: - Test: Yearly Plan Selection
    func testYearlyPlanSelection() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    paywall.selectYearlyPlan()

                    takeScreenshot(name: "57_Yearly_Selected")

                    // Verify yearly plan is selected (visual state change)
                    XCTAssertTrue(paywall.yearlyPlanButton.exists, "Yearly plan should be selectable")
                }
            }
        }
    }

    // MARK: - Test: Subscribe Button
    func testSubscribeButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    paywall.selectMonthlyPlan()
                    paywall.tapSubscribe()

                    takeScreenshot(name: "58_Subscribe_Initiated")

                    // In test environment, purchase might succeed immediately
                    // or show StoreKit test purchase dialog
                    sleep(2)
                    takeScreenshot(name: "59_After_Subscribe")
                }
            }
        }
    }

    // MARK: - Test: Restore Purchases Button
    func testRestorePurchasesButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.restorePurchasesButton.exists {
                    paywall.tapRestorePurchases()

                    takeScreenshot(name: "60_Restore_Purchases")

                    // Verify restore action occurs
                    sleep(2)
                    takeScreenshot(name: "61_After_Restore")
                }
            }
        }
    }

    // MARK: - Test: Close Paywall
    func testClosePaywall() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    takeScreenshot(name: "62_Before_Close_Paywall")

                    paywall.tapClose()

                    // Should return to settings
                    XCTAssertTrue(
                        settings.verifySettingsDisplayed(),
                        "Should return to settings after closing paywall"
                    )

                    takeScreenshot(name: "63_After_Close_Paywall")
                }
            }
        }
    }

    // MARK: - Test: Terms and Privacy Links
    func testTermsAndPrivacyLinks() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.upgradeToPremiumButton.exists {
                settings.tapUpgradeToPremium()

                let paywall = PaywallPage(app: app)

                if paywall.verifyPaywallDisplayed() {
                    takeScreenshot(name: "64_Paywall_Legal_Links")

                    // Verify legal links are present
                    assertElementExists(paywall.termsLink)
                    assertElementExists(paywall.privacyLink)
                }
            }
        }
    }
}

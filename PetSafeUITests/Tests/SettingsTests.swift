import XCTest

/// Test Suite for Settings Functionality
final class SettingsTests: PetSafeUITestBase {

    // MARK: - Test: Settings Screen Opens
    func testSettingsScreenOpens() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)
            XCTAssertTrue(settings.verifySettingsDisplayed(), "Settings should open")

            takeScreenshot(name: "41_Settings")
        }
    }

    // MARK: - Test: Dog Profile Display
    func testDogProfileDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.verifySettingsDisplayed() {
                XCTAssertTrue(
                    settings.verifyDogProfileDisplayed(),
                    "Dog profile should be displayed in settings"
                )

                takeScreenshot(name: "42_Dog_Profile")

                assertElementExists(settings.dogNameLabel)
                assertElementExists(settings.editProfileButton)
            }
        }
    }

    // MARK: - Test: Edit Profile Button
    func testEditProfileButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.verifySettingsDisplayed() && settings.editProfileButton.exists {
                settings.tapEditProfile()

                takeScreenshot(name: "43_Edit_Profile")

                // Verify edit profile screen opened
                // (Add verification for edit profile UI)
            }
        }
    }

    // MARK: - Test: Premium Subscription Status (Free User)
    func testFreeUserSubscriptionStatus() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.verifySettingsDisplayed() {
                if settings.verifyFreeStatus() {
                    takeScreenshot(name: "44_Free_User")

                    assertElementExists(settings.upgradeToPremiumButton)
                }
            }
        }
    }

    // MARK: - Test: Upgrade to Premium Button
    func testUpgradeToPremiumButton() throws {
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
                XCTAssertTrue(
                    paywall.verifyPaywallDisplayed(),
                    "Paywall should open when upgrade button is tapped"
                )

                takeScreenshot(name: "45_Paywall_From_Settings")
            }
        }
    }

    // MARK: - Test: Notifications Toggle
    func testNotificationsToggle() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.notificationsToggle.exists {
                let initialState = settings.notificationsToggle.value as? String

                settings.toggleNotifications()

                takeScreenshot(name: "46_Notifications_Toggled")

                let newState = settings.notificationsToggle.value as? String
                XCTAssertNotEqual(
                    initialState,
                    newState,
                    "Notifications toggle should change state"
                )
            }
        }
    }

    // MARK: - Test: Export Data Button
    func testExportDataButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.exportDataButton.exists {
                settings.tapExportData()

                takeScreenshot(name: "47_Export_Data")

                // Verify export dialog or action occurs
                // (Add verification for export UI)
            }
        }
    }

    // MARK: - Test: Privacy Policy Link
    func testPrivacyPolicyLink() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.privacyPolicyButton.exists {
                settings.tapPrivacyPolicy()

                takeScreenshot(name: "48_Privacy_Policy")

                // Verify privacy policy opens
                // (Add verification for web view or privacy policy screen)
            }
        }
    }

    // MARK: - Test: Terms of Service Link
    func testTermsOfServiceLink() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.termsOfServiceButton.exists {
                settings.tapTermsOfService()

                takeScreenshot(name: "49_Terms_Of_Service")

                // Verify terms opens
                // (Add verification for web view or terms screen)
            }
        }
    }

    // MARK: - Test: Logout Flow
    func testLogoutFlow() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.verifySettingsDisplayed() {
                takeScreenshot(name: "50_Before_Logout")

                settings.logout()

                // Should return to login screen
                XCTAssertTrue(
                    loginPage.verifyLoginScreenDisplayed(),
                    "Should return to login screen after logout"
                )

                takeScreenshot(name: "51_After_Logout")
            }
        }
    }

    // MARK: - Test: Close Settings
    func testCloseSettings() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)

            if settings.verifySettingsDisplayed() {
                settings.tapClose()

                // Should return to dashboard
                XCTAssertTrue(
                    dashboard.verifyDashboardDisplayed(),
                    "Should return to dashboard after closing settings"
                )

                takeScreenshot(name: "52_Settings_Closed")
            }
        }
    }
}

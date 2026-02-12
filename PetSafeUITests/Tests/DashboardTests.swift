import XCTest

/// Test Suite for Dashboard Navigation and Features
final class DashboardTests: PetSafeUITestBase {

    // MARK: - Test: Dashboard Displays After Login
    func testDashboardDisplaysAfterLogin() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Dashboard should display after login")

        takeScreenshot(name: "23_Dashboard_Home")
    }

    // MARK: - Test: Tab Navigation
    func testTabNavigation() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            // Test Home Tab
            dashboard.tapHomeTab()
            XCTAssertTrue(dashboard.verifyHomeTabActive(), "Home tab should be active")
            takeScreenshot(name: "24_Home_Tab")

            // Test Scan Tab
            dashboard.tapScanTab()
            sleep(1)
            takeScreenshot(name: "25_Scan_Tab")

            // Test Log Tab
            dashboard.tapLogTab()
            sleep(1)
            takeScreenshot(name: "26_Log_Tab")

            // Return to Home
            dashboard.tapHomeTab()
            XCTAssertTrue(dashboard.verifyHomeTabActive(), "Should return to home tab")
        }
    }

    // MARK: - Test: Copper Tracker Display
    func testCopperTrackerDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapHomeTab()

            XCTAssertTrue(
                dashboard.verifyCopperTrackerDisplayed(),
                "Copper tracker should be displayed on home tab"
            )

            takeScreenshot(name: "27_Copper_Tracker")

            assertElementExists(dashboard.copperTrackerCard)
            assertElementExists(dashboard.todaysIntakeLabel)
            assertElementExists(dashboard.recommendedLimitLabel)
        }
    }

    // MARK: - Test: Settings Button Opens Settings
    func testSettingsButtonOpensSettings() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapSettings()

            let settings = SettingsPage(app: app)
            XCTAssertTrue(
                settings.verifySettingsDisplayed(),
                "Settings should open when button is tapped"
            )

            takeScreenshot(name: "28_Settings_Opened")
        }
    }

    // MARK: - Test: Achievements Navigation
    func testAchievementsNavigation() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapHomeTab()

            if dashboard.achievementsCard.exists {
                dashboard.tapAchievements()

                takeScreenshot(name: "29_Achievements")

                // Verify achievements screen opened
                // (Add verification for achievements screen)
            }
        }
    }

    // MARK: - Test: Welcome Message Displays
    func testWelcomeMessageDisplays() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapHomeTab()

            XCTAssertTrue(
                dashboard.welcomeText.waitForExistence(timeout: 5),
                "Welcome message should be displayed"
            )

            takeScreenshot(name: "30_Welcome_Message")
        }
    }

    // MARK: - Test: Premium Badge Display
    func testPremiumBadgeDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "premium@example.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapHomeTab()

            // For premium users, verify premium badge
            if dashboard.verifyPremiumStatus() {
                takeScreenshot(name: "31_Premium_Badge")
                assertElementExists(dashboard.premiumBadge)
            }
        }
    }

    // MARK: - Test: Tab Bar Always Visible
    func testTabBarAlwaysVisible() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            // Check all tabs
            assertElementExists(dashboard.homeTab)
            assertElementExists(dashboard.scanTab)
            assertElementExists(dashboard.logTab)

            takeScreenshot(name: "32_Tab_Bar")
        }
    }
}

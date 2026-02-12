import XCTest

/// Test Suite for Complete End-to-End User Journeys
final class End2EndTests: PetSafeUITestBase {

    // MARK: - Test: Complete New User Journey
    func testCompleteNewUserJourney() throws {
        app.launch()

        takeScreenshot(name: "E2E_01_App_Launch")

        // Step 1: Login
        let loginPage = LoginPage(app: app)
        XCTAssertTrue(loginPage.verifyLoginScreenDisplayed(), "Login screen should display")
        loginPage.login(email: "newuser@example.com", password: "test123")

        takeScreenshot(name: "E2E_02_After_Login")

        // Step 2: Complete Onboarding
        let onboarding = OnboardingPage(app: app)
        if onboarding.verifyOnboardingStarted() {
            onboarding.completeOnboarding(
                dogName: "Max",
                breed: "Golden Retriever",
                age: "4",
                weight: "70"
            )
        }

        takeScreenshot(name: "E2E_03_After_Onboarding")

        // Step 3: Verify Dashboard
        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_04_Dashboard")

        // Step 4: Navigate tabs
        dashboard.tapScanTab()
        takeScreenshot(name: "E2E_05_Scan_Tab")

        dashboard.tapLogTab()
        takeScreenshot(name: "E2E_06_Log_Tab")

        dashboard.tapHomeTab()
        takeScreenshot(name: "E2E_07_Home_Tab")

        // Step 5: Open Settings
        dashboard.tapSettings()
        let settings = SettingsPage(app: app)
        XCTAssertTrue(settings.verifySettingsDisplayed(), "Settings should open")

        takeScreenshot(name: "E2E_08_Settings")

        // Step 6: Close Settings
        settings.tapClose()
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should return to dashboard")

        takeScreenshot(name: "E2E_09_Complete")
    }

    // MARK: - Test: Scanning and Logging Food Journey
    func testScanAndLogFoodJourney() throws {
        app.launch()

        // Login
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_10_Start_Scan_Journey")

        // Step 1: Open Scanner
        dashboard.tapScanTab()

        let scanner = ScannerPage(app: app)
        if scanner.verifyScannerDisplayed() {
            takeScreenshot(name: "E2E_11_Scanner_Open")

            // Wait for camera to initialize
            sleep(2)
            takeScreenshot(name: "E2E_12_Camera_Active")

            // Close scanner
            scanner.tapClose()
        }

        takeScreenshot(name: "E2E_13_Back_To_Dashboard")

        // Step 2: Check Food Log
        dashboard.tapLogTab()

        let foodLog = FoodLogPage(app: app)
        XCTAssertTrue(foodLog.verifyFoodLogDisplayed(), "Food log should display")

        takeScreenshot(name: "E2E_14_Food_Log")
    }

    // MARK: - Test: Premium Upgrade Journey
    func testPremiumUpgradeJourney() throws {
        app.launch()

        // Login
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_15_Start_Premium_Journey")

        // Step 1: Open Settings
        dashboard.tapSettings()

        let settings = SettingsPage(app: app)
        XCTAssertTrue(settings.verifySettingsDisplayed(), "Settings should open")

        takeScreenshot(name: "E2E_16_Settings")

        // Step 2: Tap Upgrade to Premium
        if settings.upgradeToPremiumButton.exists {
            settings.tapUpgradeToPremium()

            let paywall = PaywallPage(app: app)
            XCTAssertTrue(paywall.verifyPaywallDisplayed(), "Paywall should display")

            takeScreenshot(name: "E2E_17_Paywall")

            // Step 3: Select Plan
            paywall.selectYearlyPlan()
            takeScreenshot(name: "E2E_18_Plan_Selected")

            // Step 4: Close without purchasing
            paywall.tapClose()

            takeScreenshot(name: "E2E_19_Paywall_Closed")
        }

        // Verify back at settings
        XCTAssertTrue(settings.verifySettingsDisplayed(), "Should return to settings")
    }

    // MARK: - Test: Complete Logout Journey
    func testLogoutJourney() throws {
        app.launch()

        // Login
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_20_Before_Logout")

        // Open Settings
        dashboard.tapSettings()

        let settings = SettingsPage(app: app)
        XCTAssertTrue(settings.verifySettingsDisplayed(), "Settings should open")

        // Logout
        settings.logout()

        // Verify back at login
        XCTAssertTrue(loginPage.verifyLoginScreenDisplayed(), "Should return to login")

        takeScreenshot(name: "E2E_21_After_Logout")
    }

    // MARK: - Test: Achievement Viewing Journey
    func testAchievementViewingJourney() throws {
        app.launch()

        // Login
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_22_Dashboard")

        // Navigate to Achievements
        dashboard.tapHomeTab()

        if dashboard.achievementsCard.exists {
            dashboard.tapAchievements()

            takeScreenshot(name: "E2E_23_Achievements")

            // Verify achievements screen
            // (Add verification for achievements UI)
        }
    }

    // MARK: - Test: Quick Scan to Food Log Journey
    func testQuickScanToFoodLogJourney() throws {
        app.launch()

        // Login
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(dashboard.verifyDashboardDisplayed(), "Should reach dashboard")

        takeScreenshot(name: "E2E_24_Home")

        // Step 1: Quick Scan from Home
        if dashboard.quickScanButton.exists {
            dashboard.tapQuickScan()

            let scanner = ScannerPage(app: app)
            XCTAssertTrue(scanner.verifyScannerDisplayed(), "Scanner should open")

            takeScreenshot(name: "E2E_25_Quick_Scan")

            // Close scanner
            scanner.tapClose()
        }

        // Step 2: Check Food Log
        dashboard.tapLogTab()

        let foodLog = FoodLogPage(app: app)
        XCTAssertTrue(foodLog.verifyFoodLogDisplayed(), "Food log should display")

        takeScreenshot(name: "E2E_26_Food_Log_From_Quick_Scan")
    }
}

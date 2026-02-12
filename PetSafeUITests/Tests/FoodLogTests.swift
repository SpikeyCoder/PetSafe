import XCTest

/// Test Suite for Food Log Functionality
final class FoodLogTests: PetSafeUITestBase {

    // MARK: - Test: Food Log Tab Display
    func testFoodLogTabDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)
            XCTAssertTrue(foodLog.verifyFoodLogDisplayed(), "Food log should be displayed")

            takeScreenshot(name: "33_Food_Log")
        }
    }

    // MARK: - Test: Empty State Display
    func testEmptyStateDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.verifyEmptyState() {
                takeScreenshot(name: "34_Empty_State")

                assertElementExists(foodLog.emptyStateText)
                assertElementExists(foodLog.startTrackingButton)
            }
        }
    }

    // MARK: - Test: Add Food Button
    func testAddFoodButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.addFoodButton.exists {
                foodLog.tapAddFood()

                takeScreenshot(name: "35_Add_Food")

                // Should open scanner or add food dialog
                // Verify navigation occurred
            }
        }
    }

    // MARK: - Test: Food Entries Display
    func testFoodEntriesDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.verifyFoodEntriesDisplayed() {
                takeScreenshot(name: "36_Food_Entries")

                // Verify sections exist
                XCTAssertTrue(
                    foodLog.todaySection.exists || foodLog.yesterdaySection.exists,
                    "Food entry sections should be displayed"
                )
            }
        }
    }

    // MARK: - Test: Total Copper Display
    func testTotalCopperDisplay() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.verifyTotalCopperDisplayed() {
                takeScreenshot(name: "37_Total_Copper")

                assertElementExists(foodLog.totalCopperLabel)
            }
        }
    }

    // MARK: - Test: Delete Food Entry
    func testDeleteFoodEntry() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.verifyFoodEntriesDisplayed() {
                takeScreenshot(name: "38_Before_Delete")

                // Try to delete first entry
                let testEntryName = "Test Food"
                if foodLog.verifyFoodEntryExists(named: testEntryName) {
                    foodLog.deleteFoodEntry(named: testEntryName)

                    takeScreenshot(name: "39_After_Delete")

                    // Verify entry was deleted
                    sleep(1)
                    XCTAssertFalse(
                        foodLog.verifyFoodEntryExists(named: testEntryName),
                        "Food entry should be deleted"
                    )
                }
            }
        }
    }

    // MARK: - Test: Filter Button
    func testFilterButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapLogTab()

            let foodLog = FoodLogPage(app: app)

            if foodLog.filterButton.exists {
                foodLog.tapFilter()

                takeScreenshot(name: "40_Filter_Options")

                // Verify filter options appear
                // (Add verification for filter UI)
            }
        }
    }
}

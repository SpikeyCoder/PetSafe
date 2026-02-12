import XCTest

/// Page Object for Food Log Screen
struct FoodLogPage {
    let app: XCUIApplication

    // MARK: - Elements
    var foodLogTitle: XCUIElement {
        app.navigationBars["Food Log"]
    }

    var emptyStateText: XCUIElement {
        app.staticTexts["No food entries yet"]
    }

    var startTrackingButton: XCUIElement {
        app.buttons["Start Tracking"]
    }

    var addFoodButton: XCUIElement {
        app.buttons["add_food_button"]
    }

    var filterButton: XCUIElement {
        app.buttons["filter_button"]
    }

    var todaySection: XCUIElement {
        app.staticTexts["Today"]
    }

    var yesterdaySection: XCUIElement {
        app.staticTexts["Yesterday"]
    }

    // Food Entry Elements
    func foodEntry(withName name: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch
    }

    var totalCopperLabel: XCUIElement {
        app.staticTexts["total_copper_label"]
    }

    var deleteEntryButton: XCUIElement {
        app.buttons["Delete"]
    }

    // MARK: - Actions
    func tapAddFood() {
        addFoodButton.tap()
    }

    func tapStartTracking() {
        startTrackingButton.tap()
    }

    func tapFilter() {
        filterButton.tap()
    }

    func deleteFoodEntry(named name: String) {
        let entry = foodEntry(withName: name)
        entry.swipeLeft()
        deleteEntryButton.tap()
    }

    // MARK: - Verifications
    func verifyFoodLogDisplayed() -> Bool {
        return foodLogTitle.waitForExistence(timeout: 5)
    }

    func verifyEmptyState() -> Bool {
        return emptyStateText.exists &&
               startTrackingButton.exists
    }

    func verifyFoodEntriesDisplayed() -> Bool {
        return todaySection.exists || yesterdaySection.exists
    }

    func verifyTotalCopperDisplayed() -> Bool {
        return totalCopperLabel.exists
    }

    func verifyFoodEntryExists(named name: String) -> Bool {
        return foodEntry(withName: name).exists
    }
}

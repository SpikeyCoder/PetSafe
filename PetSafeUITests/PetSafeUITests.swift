import XCTest

/// Base test class with common setup and utilities
class PetSafeUITestBase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launchEnvironment = [
            "ANTHROPIC_LOG": "debug",
            "UI_TEST_MODE": "true",
            "SKIP_ANIMATIONS": "true"
        ]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    /// Wait for element to exist with timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

    /// Take screenshot with descriptive name
    func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Verify element exists and is hittable
    func assertElementExists(_ element: XCUIElement, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(element.exists, "Element should exist", file: file, line: line)
        XCTAssertTrue(element.isHittable, "Element should be hittable", file: file, line: line)
    }

    /// Print debug info about current screen
    func debugPrintScreenState(label: String = "Screen State") {
        print("\n========== \(label) ==========")
        print("Buttons: \(app.buttons.allElementsBoundByIndex.count)")
        app.buttons.allElementsBoundByIndex.forEach { button in
            if button.exists {
                print("  - \(button.identifier): '\(button.label)'")
            }
        }
        print("Text Fields: \(app.textFields.allElementsBoundByIndex.count)")
        print("Static Texts: \(app.staticTexts.allElementsBoundByIndex.count)")
        print("================================\n")
    }
}

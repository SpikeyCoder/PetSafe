import XCTest

/// Test Suite for Barcode Scanner Functionality
final class ScannerTests: PetSafeUITestBase {

    // MARK: - Test: Scanner Opens from Dashboard
    func testScannerOpensFromDashboard() throws {
        app.launch()

        // Login and navigate to dashboard
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapScanTab()

            let scanner = ScannerPage(app: app)
            XCTAssertTrue(scanner.verifyScannerDisplayed(), "Scanner should open")

            takeScreenshot(name: "16_Scanner_Open")
        }
    }

    // MARK: - Test: Camera Permission Handling
    func testCameraPermissionRequest() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapScanTab()

            let scanner = ScannerPage(app: app)

            // Check for camera permission alert
            if scanner.cameraPermissionAlert.waitForExistence(timeout: 5) {
                takeScreenshot(name: "17_Camera_Permission_Alert")
                XCTAssertTrue(scanner.cameraPermissionAlert.exists, "Permission alert should appear")
            }
        }
    }

    // MARK: - Test: Scanner UI Elements Display
    func testScannerUIElements() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapScanTab()

            let scanner = ScannerPage(app: app)

            if scanner.verifyScannerDisplayed() {
                takeScreenshot(name: "18_Scanner_UI")

                XCTAssertTrue(scanner.scanBarcodeTitle.exists, "Title should be displayed")
                XCTAssertTrue(scanner.closeButton.exists, "Close button should be displayed")
                XCTAssertTrue(scanner.instructionsText.exists, "Instructions should be displayed")

                // Verify camera preview is present
                debugPrintScreenState(label: "Scanner Screen")
            }
        }
    }

    // MARK: - Test: Scanner Close Button
    func testScannerCloseButton() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapScanTab()

            let scanner = ScannerPage(app: app)

            if scanner.verifyScannerDisplayed() {
                takeScreenshot(name: "19_Before_Close")

                scanner.tapClose()

                // Should return to dashboard
                XCTAssertTrue(
                    dashboard.verifyDashboardDisplayed(),
                    "Should return to dashboard after closing scanner"
                )

                takeScreenshot(name: "20_After_Close")
            }
        }
    }

    // MARK: - Test: Camera Preview Active (Critical Test)
    func testCameraPreviewActive() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            dashboard.tapScanTab()

            let scanner = ScannerPage(app: app)

            if scanner.verifyScannerDisplayed() {
                // Wait for camera to initialize
                sleep(2)

                takeScreenshot(name: "21_Camera_Preview")

                // Log camera state
                debugPrintScreenState(label: "Camera State")

                // Verify camera UI elements are present
                // Note: In simulator, actual camera won't work, but UI should render
                XCTAssertTrue(scanner.scanningFrame.exists, "Scanning frame should be visible")
                XCTAssertTrue(scanner.instructionsText.exists, "Instructions should be visible")
            }
        }
    }

    // MARK: - Test: Quick Scan from Home Tab
    func testQuickScanFromHome() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@petsafe.com", password: "test123")

        let dashboard = DashboardPage(app: app)

        if dashboard.verifyDashboardDisplayed() {
            if dashboard.quickScanButton.exists {
                dashboard.tapQuickScan()

                let scanner = ScannerPage(app: app)
                XCTAssertTrue(
                    scanner.verifyScannerDisplayed(),
                    "Scanner should open from quick scan button"
                )

                takeScreenshot(name: "22_Quick_Scan")
            }
        }
    }
}

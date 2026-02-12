import XCTest

/// Page Object for Barcode Scanner Screen
struct ScannerPage {
    let app: XCUIApplication

    // MARK: - Elements
    var closeButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == 'xmark'")).firstMatch
    }

    var scanBarcodeTitle: XCUIElement {
        app.staticTexts["Scan Barcode"]
    }

    var cameraPreview: XCUIElement {
        app.otherElements["camera_preview"]
    }

    var scanningFrame: XCUIElement {
        app.otherElements["scanning_frame"]
    }

    var instructionsText: XCUIElement {
        app.staticTexts["Position barcode in frame"]
    }

    var processingIndicator: XCUIElement {
        app.staticTexts["Looking up product..."]
    }

    // Permission Elements
    var cameraPermissionAlert: XCUIElement {
        app.alerts["Camera Access Required"]
    }

    var openSettingsButton: XCUIElement {
        app.buttons["Open Settings"]
    }

    // Product Result Elements
    var productNameLabel: XCUIElement {
        app.staticTexts["product_name"]
    }

    var copperContentLabel: XCUIElement {
        app.staticTexts["copper_content"]
    }

    var safetyBadge: XCUIElement {
        app.images["safety_badge"]
    }

    var addToLogButton: XCUIElement {
        app.buttons["Add to Log"]
    }

    var rescanButton: XCUIElement {
        app.buttons["Scan Another"]
    }

    // MARK: - Actions
    func tapClose() {
        closeButton.tap()
    }

    func allowCameraAccess() {
        if cameraPermissionAlert.waitForExistence(timeout: 5) {
            openSettingsButton.tap()
        }
    }

    func tapAddToLog() {
        addToLogButton.tap()
    }

    func tapRescan() {
        rescanButton.tap()
    }

    // MARK: - Verifications
    func verifyScannerDisplayed() -> Bool {
        return scanBarcodeTitle.waitForExistence(timeout: 5) &&
               closeButton.exists
    }

    func verifyCameraPreviewActive() -> Bool {
        return cameraPreview.exists &&
               scanningFrame.exists &&
               instructionsText.exists
    }

    func verifyProductResultDisplayed() -> Bool {
        return productNameLabel.waitForExistence(timeout: 10) &&
               copperContentLabel.exists &&
               safetyBadge.exists
    }

    func verifyProcessingIndicator() -> Bool {
        return processingIndicator.exists
    }
}

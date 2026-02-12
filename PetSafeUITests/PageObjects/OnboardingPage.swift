import XCTest

/// Page Object for Onboarding Flow
struct OnboardingPage {
    let app: XCUIApplication

    // MARK: - Common Elements
    var nextButton: XCUIElement {
        app.buttons["Next"]
    }

    var backButton: XCUIElement {
        app.buttons["Back"]
    }

    var skipButton: XCUIElement {
        app.buttons["Skip"]
    }

    // MARK: - Step 1: Dog Name
    var dogNameTextField: XCUIElement {
        app.textFields["dog_name_field"]
    }

    var welcomeText: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'dog'")).firstMatch
    }

    // MARK: - Step 2: Breed Selection
    var breedSearchField: XCUIElement {
        app.searchFields["Search breeds"]
    }

    func breedOption(_ breedName: String) -> XCUIElement {
        app.staticTexts[breedName]
    }

    // MARK: - Step 3: Age & Weight
    var ageTextField: XCUIElement {
        app.textFields["age_field"]
    }

    var weightTextField: XCUIElement {
        app.textFields["weight_field"]
    }

    var agePicker: XCUIElement {
        app.pickers["age_picker"]
    }

    var weightPicker: XCUIElement {
        app.pickers["weight_picker"]
    }

    // MARK: - Step 4: Health Conditions
    var copperStorageDiseaseToggle: XCUIElement {
        app.switches["copper_storage_disease_toggle"]
    }

    var otherConditionsTextField: XCUIElement {
        app.textViews["other_conditions_field"]
    }

    // MARK: - Step 5: Primary Concerns
    var concernsCheckbox: XCUIElement {
        app.buttons["concern_checkbox"]
    }

    // MARK: - Final Step: Review & Complete
    var reviewProfileText: XCUIElement {
        app.staticTexts["Review your profile"]
    }

    var completeButton: XCUIElement {
        app.buttons["Complete Setup"]
    }

    // MARK: - Actions
    func enterDogName(_ name: String) {
        dogNameTextField.tap()
        dogNameTextField.typeText(name)
    }

    func tapNext() {
        nextButton.tap()
    }

    func tapBack() {
        backButton.tap()
    }

    func searchBreed(_ breed: String) {
        breedSearchField.tap()
        breedSearchField.typeText(breed)
    }

    func selectBreed(_ breedName: String) {
        breedOption(breedName).tap()
    }

    func enterAge(_ age: String) {
        ageTextField.tap()
        ageTextField.typeText(age)
    }

    func enterWeight(_ weight: String) {
        weightTextField.tap()
        weightTextField.typeText(weight)
    }

    func toggleCopperStorageDisease() {
        copperStorageDiseaseToggle.tap()
    }

    func tapComplete() {
        completeButton.tap()
    }

    // MARK: - Complete Onboarding Flow
    func completeOnboarding(dogName: String, breed: String, age: String, weight: String) {
        // Step 1: Name
        if dogNameTextField.waitForExistence(timeout: 5) {
            enterDogName(dogName)
            tapNext()
        }

        // Step 2: Breed
        if breedSearchField.waitForExistence(timeout: 5) {
            searchBreed(breed)
            selectBreed(breed)
            tapNext()
        }

        // Step 3: Age & Weight
        if ageTextField.waitForExistence(timeout: 5) {
            enterAge(age)
            enterWeight(weight)
            tapNext()
        }

        // Step 4: Health (skip)
        if copperStorageDiseaseToggle.waitForExistence(timeout: 5) {
            tapNext()
        }

        // Step 5: Concerns (skip)
        if concernsCheckbox.waitForExistence(timeout: 5) {
            tapNext()
        }

        // Final: Complete
        if completeButton.waitForExistence(timeout: 5) {
            tapComplete()
        }
    }

    // MARK: - Verifications
    func verifyOnboardingStarted() -> Bool {
        return dogNameTextField.waitForExistence(timeout: 10)
    }

    func verifyBreedStepDisplayed() -> Bool {
        return breedSearchField.exists
    }

    func verifyAgeWeightStepDisplayed() -> Bool {
        return ageTextField.exists && weightTextField.exists
    }

    func verifyCompletionStepDisplayed() -> Bool {
        return reviewProfileText.exists && completeButton.exists
    }
}

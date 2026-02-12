import XCTest

/// Test Suite for Onboarding Flow
final class OnboardingTests: PetSafeUITestBase {

    // MARK: - Test: Complete Onboarding Flow
    func testCompleteOnboardingFlow() throws {
        app.launch()

        // Login first
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let onboarding = OnboardingPage(app: app)

        // Verify onboarding starts
        XCTAssertTrue(onboarding.verifyOnboardingStarted(), "Onboarding should start for new users")
        takeScreenshot(name: "08_Onboarding_Start")

        // Complete the flow
        onboarding.completeOnboarding(
            dogName: "Buddy",
            breed: "Labrador Retriever",
            age: "3",
            weight: "65"
        )

        // Should navigate to dashboard
        let dashboard = DashboardPage(app: app)
        XCTAssertTrue(
            dashboard.verifyDashboardDisplayed(),
            "Should navigate to dashboard after onboarding"
        )
        takeScreenshot(name: "09_Onboarding_Complete")
    }

    // MARK: - Test: Dog Name Entry
    func testDogNameEntry() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let onboarding = OnboardingPage(app: app)

        if onboarding.verifyOnboardingStarted() {
            onboarding.enterDogName("Max")

            takeScreenshot(name: "10_DogName_Entered")

            XCTAssertEqual(onboarding.dogNameTextField.value as? String, "Max", "Dog name should be entered")

            onboarding.tapNext()

            // Should progress to next step
            XCTAssertTrue(onboarding.verifyBreedStepDisplayed(), "Should navigate to breed selection")
        }
    }

    // MARK: - Test: Breed Search and Selection
    func testBreedSearchAndSelection() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let onboarding = OnboardingPage(app: app)

        // Navigate to breed step
        if onboarding.verifyOnboardingStarted() {
            onboarding.enterDogName("Test Dog")
            onboarding.tapNext()

            if onboarding.verifyBreedStepDisplayed() {
                onboarding.searchBreed("Golden")

                takeScreenshot(name: "11_Breed_Search")

                // Verify search results appear
                let goldenRetriever = onboarding.breedOption("Golden Retriever")
                XCTAssertTrue(
                    goldenRetriever.waitForExistence(timeout: 5),
                    "Breed should appear in search results"
                )

                onboarding.selectBreed("Golden Retriever")
                onboarding.tapNext()

                takeScreenshot(name: "12_Breed_Selected")
            }
        }
    }

    // MARK: - Test: Back Navigation
    func testBackNavigation() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let onboarding = OnboardingPage(app: app)

        if onboarding.verifyOnboardingStarted() {
            onboarding.enterDogName("Test")
            onboarding.tapNext()

            if onboarding.verifyBreedStepDisplayed() {
                takeScreenshot(name: "13_Before_Back")

                onboarding.tapBack()

                // Should return to dog name step
                XCTAssertTrue(
                    onboarding.dogNameTextField.waitForExistence(timeout: 5),
                    "Should navigate back to previous step"
                )

                takeScreenshot(name: "14_After_Back")
            }
        }
    }

    // MARK: - Test: Age and Weight Entry
    func testAgeAndWeightEntry() throws {
        app.launch()

        let loginPage = LoginPage(app: app)
        loginPage.login(email: "newuser@example.com", password: "test123")

        let onboarding = OnboardingPage(app: app)

        if onboarding.verifyOnboardingStarted() {
            // Navigate to age/weight step
            onboarding.enterDogName("Test")
            onboarding.tapNext()

            if onboarding.verifyBreedStepDisplayed() {
                onboarding.searchBreed("Beagle")
                onboarding.selectBreed("Beagle")
                onboarding.tapNext()

                if onboarding.verifyAgeWeightStepDisplayed() {
                    onboarding.enterAge("5")
                    onboarding.enterWeight("45")

                    takeScreenshot(name: "15_Age_Weight_Entered")

                    XCTAssertEqual(
                        onboarding.ageTextField.value as? String,
                        "5",
                        "Age should be entered"
                    )
                }
            }
        }
    }
}

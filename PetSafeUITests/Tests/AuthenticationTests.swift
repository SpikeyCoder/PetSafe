import XCTest

/// Test Suite for Authentication Flows
final class AuthenticationTests: PetSafeUITestBase {

    // MARK: - Test: Login Screen Display
    func testLoginScreenDisplays() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        takeScreenshot(name: "01_LoginScreen")

        XCTAssertTrue(loginPage.verifyLoginScreenDisplayed(), "Login screen should be displayed")
        assertElementExists(loginPage.emailTextField)
        assertElementExists(loginPage.passwordTextField)
        assertElementExists(loginPage.loginButton)
    }

    // MARK: - Test: Valid Login
    func testValidLogin() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        loginPage.login(email: "test@petsafe.com", password: "test123")

        // Should navigate to dashboard or onboarding
        let dashboard = DashboardPage(app: app)
        let onboarding = OnboardingPage(app: app)

        let isDashboard = dashboard.verifyDashboardDisplayed()
        let isOnboarding = onboarding.verifyOnboardingStarted()

        takeScreenshot(name: "02_AfterLogin")

        XCTAssertTrue(isDashboard || isOnboarding, "Should navigate after successful login")
    }

    // MARK: - Test: Invalid Email Format
    func testInvalidEmailFormat() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        loginPage.enterEmail("invalid-email")
        loginPage.enterPassword("test123")
        loginPage.tapLogin()

        takeScreenshot(name: "03_InvalidEmail")

        // Should show error or prevent login
        XCTAssertTrue(loginPage.verifyLoginScreenDisplayed(), "Should remain on login screen")
    }

    // MARK: - Test: Empty Fields
    func testEmptyFieldsValidation() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        loginPage.tapLogin()

        takeScreenshot(name: "04_EmptyFields")

        // Should show validation error or prevent login
        XCTAssertTrue(loginPage.verifyLoginScreenDisplayed(), "Should remain on login screen")
    }

    // MARK: - Test: Create Account Button
    func testCreateAccountNavigation() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        if loginPage.createAccountButton.exists {
            loginPage.tapCreateAccount()

            takeScreenshot(name: "05_CreateAccount")

            // Should navigate to create account screen
            // Verify navigation occurred
        }
    }

    // MARK: - Test: Forgot Password Button
    func testForgotPasswordNavigation() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        if loginPage.forgotPasswordButton.exists {
            loginPage.tapForgotPassword()

            takeScreenshot(name: "06_ForgotPassword")

            // Should navigate to forgot password screen
            // Verify navigation occurred
        }
    }

    // MARK: - Test: Sign in with Apple
    func testSignInWithApple() throws {
        app.launch()
        let loginPage = LoginPage(app: app)

        if loginPage.signInWithAppleButton.exists {
            takeScreenshot(name: "07_SignInWithApple_Available")
            assertElementExists(loginPage.signInWithAppleButton)
        }
    }
}

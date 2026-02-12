import XCTest

/// Page Object for Login Screen
struct LoginPage {
    let app: XCUIApplication

    // MARK: - Elements
    var emailTextField: XCUIElement {
        app.textFields["email_field"]
    }

    var passwordTextField: XCUIElement {
        app.secureTextFields["password_field"]
    }

    var loginButton: XCUIElement {
        app.buttons["login_button"]
    }

    var createAccountButton: XCUIElement {
        app.buttons["create_account_button"]
    }

    var forgotPasswordButton: XCUIElement {
        app.buttons["forgot_password_button"]
    }

    var signInWithAppleButton: XCUIElement {
        app.buttons["Sign in with Apple"]
    }

    // MARK: - Actions
    func enterEmail(_ email: String) {
        emailTextField.tap()
        emailTextField.typeText(email)
    }

    func enterPassword(_ password: String) {
        passwordTextField.tap()
        passwordTextField.typeText(password)
    }

    func tapLogin() {
        loginButton.tap()
    }

    func tapCreateAccount() {
        createAccountButton.tap()
    }

    func tapForgotPassword() {
        forgotPasswordButton.tap()
    }

    func login(email: String, password: String) {
        enterEmail(email)
        enterPassword(password)
        tapLogin()
    }

    // MARK: - Verifications
    func verifyLoginScreenDisplayed() -> Bool {
        return emailTextField.waitForExistence(timeout: 5) &&
               passwordTextField.exists &&
               loginButton.exists
    }
}

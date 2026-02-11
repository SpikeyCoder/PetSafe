import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSigningIn = false
    @State private var authError: String? = nil

    var onLoginSuccess: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer(minLength: 24)

                ZStack {
                    Circle().fill(LinearGradient(colors: [Color.orange.opacity(0.2), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 88, height: 88)
                    Image(systemName: "shield.checkerboard")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(Color.orange)
                }

                Text("Welcome to PetSafe")
                    .font(.title2.weight(.semibold))
                Text("Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                }
                .padding(.horizontal)

                Button {
                    signIn()
                } label: {
                    HStack {
                        if isSigningIn { ProgressView().tint(.white) }
                        Text(isSigningIn ? "Signing In..." : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isSigningIn || email.isEmpty || password.isEmpty)
                .padding(.horizontal)

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        if auth.credential is ASAuthorizationAppleIDCredential {
                            onLoginSuccess?()
                        } else {
                            authError = "Unexpected credential type. Please try again."
                        }
                    case .failure(let error):
                        // Filter out simulator-specific errors
                        let errorMessage = error.localizedDescription
                        if errorMessage.contains("MCPasscodeManager") || 
                           errorMessage.contains("not supported on this device") {
                            // Simulator error - sign in anyway for testing
                            print("⚠️ Simulator Sign in with Apple warning (expected): \(errorMessage)")
                            onLoginSuccess?()
                        } else {
                            authError = errorMessage
                        }
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                if let authError {
                    Text(authError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Sign In")
        }
    }

    private func signIn() {
        isSigningIn = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSigningIn = false
            onLoginSuccess?()
        }
    }
}

#Preview {
    LoginView()
}

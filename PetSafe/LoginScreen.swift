import SwiftUI

struct LoginScreen: View {
    let onLogin: (String) -> Void

    @State private var isLoadingProvider: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.2)).frame(width: 72, height: 72)
                        Image(systemName: "shield.checkerboard").foregroundStyle(Color.orange)
                    }
                    Text("Welcome to PetSafe").font(.title2.weight(.semibold))
                    Text("Monitor your dog's special diet intake and keep them healthy")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    loginButton(title: "Continue with Google", systemImage: "g.circle", bg: .white, fg: .black, provider: "google")
                    loginButton(title: "Continue with Facebook", systemImage: "f.cursive.circle", bg: Color(red: 0.09, green: 0.47, blue: 0.95), fg: .white, provider: "facebook")
                    loginButton(title: "Continue with Apple", systemImage: "apple.logo", bg: .black, fg: .white, provider: "apple")
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("What you'll get:").font(.headline)
                    bullet("Comprehensive food database with copper content")
                    bullet("Breed-specific risk assessments")
                    bullet("Daily intake tracking and alerts")
                    bullet("Barcode scanning for easy food logging")
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()
                Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Login")
        }
    }

    @ViewBuilder private func loginButton(title: String, systemImage: String, bg: Color, fg: Color, provider: String) -> some View {
        Button {
            isLoadingProvider = provider
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isLoadingProvider = nil
                onLogin(provider)
            }
        } label: {
            HStack {
                if isLoadingProvider == provider {
                    ProgressView().tint(fg)
                } else {
                    Image(systemName: systemImage)
                }
                Text(title).fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(bg)
            .foregroundStyle(fg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(bg == .white ? 0.3 : 0), lineWidth: 1))
        }
        .disabled(isLoadingProvider != nil)
    }

    @ViewBuilder private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.orange).frame(width: 6, height: 6).padding(.top, 6)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
    }
}

#Preview {
    LoginScreen { provider in
        print("Logged in with \(provider)")
    }
}

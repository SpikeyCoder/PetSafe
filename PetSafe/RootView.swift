import SwiftUI

struct RootView: View {
    @State private var isLoading = true
    @State private var isAuthenticated = false
    @State private var isFirstLogin = true // simulate first-time; later, tie to persisted state
    @State private var onboardingData: OnboardingData? = nil

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
            } else if !isAuthenticated {
                LoginView(onLoginSuccess: { isAuthenticated = true })
                    .transition(.opacity)
            } else if isFirstLogin {
                OnboardingFlow(
                    onComplete: { data in
                        onboardingData = data
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isFirstLogin = false
                        }
                    },
                    onBackToLogin: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isAuthenticated = false
                        }
                    }
                )
                .transition(.opacity)
            } else {
                if let onboardingData {
                    PersonalizedInsights(
                        onboardingData: onboardingData,
                        riskLevel: inferredRiskLevel(from: onboardingData),
                        currentCopper: 1.2,
                        copperLimit: 5.0
                    )
                    .transition(.opacity)
                } else {
                    ProgressView("Loading...")
                        .transition(.opacity)
                }
            }
        }
        .task {
            // Simulate initial load
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.35)) {
                isLoading = false
            }
        }
    }

    private func inferredRiskLevel(from data: OnboardingData) -> String {
        if data.healthConditions.contains("Copper Storage Disease") { return "high" }
        if data.healthConditions.contains("Liver Disease") { return "medium" }
        return "low"
    }
}

#Preview {
    RootView()
}

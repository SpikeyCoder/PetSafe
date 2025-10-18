import SwiftUI

struct RootView: View {
    @State private var isLoading = true
    @State private var isAuthenticated = false
    @State private var isFirstLogin = true // simulate first-time; later, tie to persisted state

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
                PersonalizedInsights(
                    onboardingData: OnboardingData(
                        dogName: "Max",
                        breed: "Labrador Retriever",
                        age: 7,
                        weight: 65,
                        healthConditions: ["Copper Storage Disease"],
                        dietaryRestrictions: ["Low-copper diet"],
                        primaryConcerns: ["Copper toxicity prevention"],
                        vetRecommendations: ["Monitor copper intake"]
                    ),
                    riskLevel: "high",
                    currentCopper: 1.2,
                    copperLimit: 5.0
                )
                .transition(.opacity)
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
}

#Preview {
    RootView()
}

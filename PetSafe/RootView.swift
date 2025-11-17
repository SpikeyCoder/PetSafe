import SwiftUI

struct RootView: View {
    @State private var isLoading = true
    @State private var isAuthenticated = false
    @State private var isFirstLogin = true // simulate first-time; later, tie to persisted state
    @State private var onboardingData: PetOnboardingData? = nil

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
                    onComplete: { (data: PetOnboardingData) in
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
                        onboardingData: makeOnboardingData(from: onboardingData),
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

    func inferredRiskLevel(from data: PetOnboardingData) -> String {
        let conditions = data.healthConditions ?? []
        if conditions.contains("Copper Storage Disease") { return "high" }
        if conditions.contains("Liver Disease") { return "medium" }
        return "low"
    }
    
    private func makeOnboardingData(from pet: PetOnboardingData) -> OnboardingData {
        // Map fields from PetOnboardingData to OnboardingData using strongly-typed access.
        // Adjust the property names below to match your actual PetOnboardingData model.
        // If your OnboardingData does not include a `species` parameter, remove it here too.
        return OnboardingData(
            dogName: pet.dogName,
            breed: pet.breed,
            age: pet.age,
            weight: pet.weight,
            healthConditions: pet.healthConditions,
            dietaryRestrictions: pet.dietaryRestrictions,
            primaryConcerns: [],
            vetRecommendations: pet.vetRecommendations
        )
    }
}

#Preview {
    RootView()
}

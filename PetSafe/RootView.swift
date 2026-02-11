import SwiftUI
import SwiftData

// MARK: - Root View (Updated)
/// Main app coordinator managing authentication, onboarding, and dashboard
struct RootView_NEW: View {
    // App state
    @State private var isLoading = true
    @State private var isAuthenticated = false
    @State private var needsOnboarding = true

    // SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [DogProfile]

    private var dogProfile: DogProfile? { profiles.first }

    // Services (injected from environment or app)
    @Environment(\.openFoodFactsService) private var openFoodFactsService

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
            } else if !isAuthenticated {
                LoginView(onLoginSuccess: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isAuthenticated = true
                    }
                })
                .transition(.opacity)
            } else if needsOnboarding {
                OnboardingFlow(
                    onComplete: { data in
                        handleOnboardingComplete(data)
                    },
                    onBackToLogin: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isAuthenticated = false
                        }
                    }
                )
                .transition(.opacity)
            } else if let profile = dogProfile {
                DashboardViewWrapper(
                    modelContext: modelContext,
                    dogProfile: profile
                )
                .transition(.opacity)
            }
        }
        .task {
            await initializeApp()
        }
    }

    // MARK: - Initialization
    private func initializeApp() async {
        // Simulate initial load
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Check if profile exists
        needsOnboarding = dogProfile == nil

        withAnimation(.easeInOut(duration: 0.35)) {
            isLoading = false
        }
    }

    // MARK: - Onboarding Complete
    private func handleOnboardingComplete(_ data: PetOnboardingData) {
        // Convert onboarding data to DogProfile
        let profile = DogProfile.from(onboardingData: OnboardingData(
            dogName: data.dogName,
            breed: data.breed,
            age: data.age,
            weight: data.weight,
            healthConditions: data.healthConditions,
            dietaryRestrictions: data.dietaryRestrictions,
            primaryConcerns: data.primaryConcerns,
            vetRecommendations: data.vetRecommendations
        ))

        // Save to SwiftData
        modelContext.insert(profile)
        try? modelContext.save()

        withAnimation(.easeInOut(duration: 0.35)) {
            needsOnboarding = false
        }
    }
}

// MARK: - Dashboard Wrapper
/// Wrapper view that creates ViewModels with proper dependencies
@MainActor
private struct DashboardViewWrapper: View {
    let modelContext: ModelContext
    let dogProfile: DogProfile
    
    @StateObject private var subscriptionViewModel: SubscriptionViewModel
    @StateObject private var scannerViewModel: ScannerViewModel
    @StateObject private var foodLogViewModel: FoodLogViewModel
    
    init(modelContext: ModelContext, dogProfile: DogProfile) {
        self.modelContext = modelContext
        self.dogProfile = dogProfile
        
        // Initialize ViewModels with dependencies using the underscore syntax
        let mockSubscriptionService = SubscriptionServiceMock()
        _subscriptionViewModel = StateObject(wrappedValue: SubscriptionViewModel(subscriptionService: mockSubscriptionService))
        
        let mockOFFService = OpenFoodFactsServiceMock()
        _scannerViewModel = StateObject(wrappedValue: ScannerViewModel(
            openFoodFactsService: mockOFFService,
            dogProfile: dogProfile
        ))
        
        _foodLogViewModel = StateObject(wrappedValue: FoodLogViewModel(
            modelContext: modelContext,
            dogProfile: dogProfile
        ))
    }
    
    var body: some View {
        DashboardView(
            subscriptionViewModel: subscriptionViewModel,
            scannerViewModel: scannerViewModel,
            foodLogViewModel: foodLogViewModel
        )
        .task {
            await subscriptionViewModel.checkSubscriptionStatus()
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DogProfile.self, FoodEntry.self, configurations: config)

    let subscriptionService = SubscriptionServiceMock()

    return RootView_NEW()
        .modelContainer(container)
        .environmentObject(subscriptionService)
}

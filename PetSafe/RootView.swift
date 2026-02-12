import SwiftUI
import SwiftData

// MARK: - Root View (Updated)
/// Main app coordinator managing authentication, onboarding, and dashboard
struct RootView_NEW: View {
    // App state
    @State private var isLoading = true
    @State private var isAuthenticated = false
    @State private var needsOnboarding = true
    @State private var hasInitialized = false  // Track first initialization

    // SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [DogProfile]

    private var dogProfile: DogProfile? { profiles.first }

    // Services (injected from environment or app)
    @Environment(\.openFoodFactsService) private var openFoodFactsService
    @EnvironmentObject private var subscriptionService: SubscriptionServiceImpl

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
            } else if !isAuthenticated {
                LoginView(
                    onLoginSuccess: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isAuthenticated = true
                        }
                    },
                    onLoginWithPremium: { isPremium in
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isAuthenticated = true
                        }
                    }
                )
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
                    dogProfile: profile,
                    subscriptionService: subscriptionService,
                    onLogout: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isAuthenticated = false
                        }
                    }
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
        // UI Testing Mode: Create test profile and skip onboarding
        let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-Testing")

        print("🧪 [RootView] initializeApp - isUITesting: \(isUITesting)")
        print("🧪 [RootView] Current profiles count: \(profiles.count)")
        print("🧪 [RootView] dogProfile exists: \(dogProfile != nil)")

        if isUITesting && dogProfile == nil && !hasInitialized {
            print("🧪 [RootView] Creating test profile for UI testing (first initialization)...")
            // Create a test dog profile automatically on first run only
            let testProfile = DogProfile(
                name: "TestDog",
                breed: "Golden Retriever",
                age: 3,
                weight: 30.0,
                healthConditions: [],
                dietaryRestrictions: [],
                primaryConcerns: []
            )
            modelContext.insert(testProfile)

            do {
                try modelContext.save()
                print("✅ [RootView] Test profile saved successfully")

                // Give SwiftData a moment to update the query
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s

                print("🧪 [RootView] After save - profiles count: \(profiles.count)")
                print("🧪 [RootView] After save - dogProfile exists: \(dogProfile != nil)")

                // Force skip onboarding in UI test mode since we created a profile
                needsOnboarding = false
                hasInitialized = true  // Mark as initialized
                print("✅ [RootView] Forced needsOnboarding = false for UI testing")
            } catch {
                print("❌ [RootView] Failed to save test profile: \(error)")
                needsOnboarding = true
            }
        } else {
            // Normal flow: check if profile exists
            // Only set needsOnboarding on first initialization
            // After logout (hasInitialized = true), keep needsOnboarding = false to show login
            if !hasInitialized {
                needsOnboarding = dogProfile == nil
                hasInitialized = true
                print("🧪 [RootView] First initialization - needsOnboarding: \(needsOnboarding)")
            } else {
                // After logout: profile is nil but user already onboarded
                // Keep needsOnboarding = false to show login screen
                print("🧪 [RootView] Post-logout - keeping needsOnboarding = false")
            }
        }

        // Simulate initial load (skip delay in UI tests)
        let delay = isUITesting ? 100_000_000 : 1_500_000_000 // 0.1s vs 1.5s
        try? await Task.sleep(nanoseconds: UInt64(delay))

        print("🧪 [RootView] Final state - needsOnboarding: \(needsOnboarding), isLoading -> false")

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
    let onLogout: () -> Void

    @StateObject private var subscriptionViewModel: SubscriptionViewModel
    @StateObject private var scannerViewModel: ScannerViewModel
    @StateObject private var foodLogViewModel: FoodLogViewModel

    init(modelContext: ModelContext, dogProfile: DogProfile, subscriptionService: SubscriptionServiceImpl, onLogout: @escaping () -> Void) {
        self.modelContext = modelContext
        self.dogProfile = dogProfile
        self.onLogout = onLogout

        // Initialize ViewModels with real StoreKit service
        _subscriptionViewModel = StateObject(wrappedValue: SubscriptionViewModel(subscriptionService: subscriptionService))
        
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
            foodLogViewModel: foodLogViewModel,
            onLogout: onLogout
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

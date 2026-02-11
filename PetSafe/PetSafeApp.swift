import SwiftUI
import SwiftData

@main
struct PetSafeApp: App {
    // MARK: - SwiftData Configuration
    let modelContainer: ModelContainer

    // MARK: - Services (Dependency Injection)
    @StateObject private var subscriptionService: SubscriptionServiceImpl
    private let openFoodFactsService: OpenFoodFactsService
    private let usdaService: USDAService

    init() {
        // Configure SwiftData model container
        do {
            let schema = Schema([
                FoodEntry.self,
                DogProfile.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false // Use persistent storage
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }

        // Initialize services with real StoreKit implementation
        _subscriptionService = StateObject(wrappedValue: SubscriptionServiceImpl())
        openFoodFactsService = OpenFoodFactsServiceMock()
        usdaService = USDAServiceMock()

        // For production API services, use:
        // openFoodFactsService = OpenFoodFactsServiceImpl()
        // usdaService = USDAServiceImpl(apiKey: "YOUR_USDA_API_KEY")
    }

    var body: some Scene {
        WindowGroup {
            RootView_NEW()
                .modelContainer(modelContainer)
                .environmentObject(subscriptionService)
                .environment(\.openFoodFactsService, openFoodFactsService)
                .environment(\.usdaService, usdaService)
                .task {
                    // Load subscription products on app launch
                    try? await subscriptionService.loadProducts()
                    await subscriptionService.checkSubscriptionStatus()
                }
        }
    }
}

// MARK: - Environment Keys for Service Injection
struct OpenFoodFactsServiceKey: EnvironmentKey {
    static let defaultValue: OpenFoodFactsService = OpenFoodFactsServiceMock()
}

struct USDAServiceKey: EnvironmentKey {
    static let defaultValue: USDAService = USDAServiceMock()
}

extension EnvironmentValues {
    var openFoodFactsService: OpenFoodFactsService {
        get { self[OpenFoodFactsServiceKey.self] }
        set { self[OpenFoodFactsServiceKey.self] = newValue }
    }

    var usdaService: USDAService {
        get { self[USDAServiceKey.self] }
        set { self[USDAServiceKey.self] = newValue }
    }
}

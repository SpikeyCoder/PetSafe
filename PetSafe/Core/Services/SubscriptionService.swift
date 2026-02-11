import Foundation
import StoreKit
internal import Combine

// MARK: - Subscription Service Protocol
/// Service for managing in-app subscriptions using StoreKit 2
@MainActor
protocol SubscriptionService: ObservableObject {
    var isPremium: Bool { get }
    var availableProducts: [Product] { get }
    var purchaseState: PurchaseState { get }

    func loadProducts() async throws
    func purchase(_ product: Product) async throws
    func restorePurchases() async throws
    func checkSubscriptionStatus() async
}

// MARK: - Purchase State
enum PurchaseState: Equatable {
    case idle
    case loading
    case purchasing
    case success
    case failed(String)
    case restored

    var isLoading: Bool {
        self == .loading || self == .purchasing
    }

    var successMessage: String? {
        switch self {
        case .success:
            return "Welcome to Premium! 🎉"
        case .restored:
            return "Purchases restored successfully!"
        default:
            return nil
        }
    }
}

// MARK: - Real StoreKit 2 Implementation
@MainActor
final class SubscriptionServiceImpl: SubscriptionService {
    @Published var isPremium: Bool = false
    @Published var availableProducts: [Product] = []
    @Published var purchaseState: PurchaseState = .idle

    // Product IDs - These should match your App Store Connect configuration
    private let productIds: Set<String> = [
        "com.petsafe.premium.monthly",
        "com.petsafe.premium.yearly"
    ]

    private var updateListenerTask: Task<Void, Error>?

    init() {
        // Start listening for transaction updates
        updateListenerTask = Task {
            await listenForTransactions()
        }

        // Check subscription status on init
        Task {
            await checkSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async throws {
        purchaseState = .loading

        do {
            let products = try await Product.products(for: productIds)
            self.availableProducts = products.sorted { $0.price < $1.price }
            purchaseState = .idle
        } catch {
            purchaseState = .failed("Failed to load products: \(error.localizedDescription)")
            throw SubscriptionError.loadFailed(error)
        }
    }

    func purchase(_ product: Product) async throws {
        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update subscription status
                await checkSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()

                purchaseState = .success

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .idle

            @unknown default:
                purchaseState = .failed("Unknown purchase result")
            }
        } catch {
            purchaseState = .failed("Purchase failed: \(error.localizedDescription)")
            throw SubscriptionError.purchaseFailed(error)
        }
    }

    func restorePurchases() async throws {
        purchaseState = .loading

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            purchaseState = isPremium ? .restored : .idle
        } catch {
            purchaseState = .failed("Restore failed: \(error.localizedDescription)")
            throw SubscriptionError.restoreFailed(error)
        }
    }

    func checkSubscriptionStatus() async {
        var activeSubscription = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if it's one of our subscription products
                if productIds.contains(transaction.productID) {
                    activeSubscription = true
                    break
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        isPremium = activeSubscription

        // Persist premium status
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)

                // Update subscription status
                await checkSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Mock Implementation for Testing/Development
@MainActor
final class SubscriptionServiceMock: SubscriptionService {
    @Published var isPremium: Bool = false
    @Published var availableProducts: [Product] = []
    @Published var purchaseState: PurchaseState = .idle

    private var mockProducts: [MockProduct] = [
        MockProduct(id: "monthly", name: "Premium Monthly", price: 4.99, period: "month"),
        MockProduct(id: "yearly", name: "Premium Yearly", price: 39.99, period: "year")
    ]

    func loadProducts() async throws {
        purchaseState = .loading

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Since we can't create real Product objects in mock, we'll just update state
        purchaseState = .idle
    }

    func purchase(_ product: Product) async throws {
        purchaseState = .purchasing

        // Simulate purchase delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Simulate 90% success rate
        if Int.random(in: 1...10) <= 9 {
            isPremium = true
            purchaseState = .success
            UserDefaults.standard.set(true, forKey: "isPremium")
        } else {
            purchaseState = .failed("Mock purchase failed")
            throw SubscriptionError.purchaseFailed(NSError(domain: "Mock", code: 1))
        }
    }

    func restorePurchases() async throws {
        purchaseState = .loading

        // Simulate restore delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Check if was previously premium
        let wasPremium = UserDefaults.standard.bool(forKey: "isPremium")
        isPremium = wasPremium
        purchaseState = wasPremium ? .restored : .idle
    }

    func checkSubscriptionStatus() async {
        // Check UserDefaults
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }

    // Helper to toggle premium for testing
    func togglePremiumForTesting() {
        isPremium.toggle()
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
    }
}

// MARK: - Mock Product Model
struct MockProduct {
    let id: String
    let name: String
    let price: Double
    let period: String

    var displayPrice: String {
        String(format: "$%.2f/%@", price, period)
    }
}

// MARK: - Errors
enum SubscriptionError: LocalizedError {
    case loadFailed(Error)
    case purchaseFailed(Error)
    case restoreFailed(Error)
    case verificationFailed
    case noActiveSubscription

    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load products: \(error.localizedDescription)"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "Failed to restore purchases: \(error.localizedDescription)"
        case .verificationFailed:
            return "Transaction verification failed"
        case .noActiveSubscription:
            return "No active subscription found"
        }
    }
}

// MARK: - Product Extensions for Display
extension Product {
    var displayPrice: String {
        displayPrice
    }

    var displayPeriod: String {
        subscription?.subscriptionPeriod.unit.displayText ?? ""
    }

    var isYearly: Bool {
        subscription?.subscriptionPeriod.unit == .year
    }

    var savingsText: String? {
        guard isYearly else { return nil }
        // Calculate monthly equivalent and savings
        let monthlyEquivalent = price / 12
        let monthlyPrice: Decimal = 4.99
        let savings = monthlyPrice - monthlyEquivalent
        return String(format: "Save $%.2f/month", NSDecimalNumber(decimal: savings).doubleValue)
    }
}

extension Product.SubscriptionPeriod.Unit {
    var displayText: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return ""
        }
    }
}

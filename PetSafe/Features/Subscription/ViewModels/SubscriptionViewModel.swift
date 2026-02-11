import Foundation
internal import Combine
import SwiftUI
import StoreKit

// MARK: - Subscription ViewModel
/// Manages premium subscription state and purchase flow
@MainActor
final class SubscriptionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    @Published var availableProducts: [Product] = []
    @Published var selectedProduct: Product?
    @Published var purchaseState: PurchaseState = .idle
    @Published var showPaywall: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let subscriptionService: any SubscriptionService

    // MARK: - Premium Features List
    let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(
            icon: "camera.viewfinder",
            title: "Barcode Scanner",
            description: "Instantly scan product barcodes to check copper content and safety levels"
        ),
        PremiumFeature(
            icon: "photo.on.rectangle.angled",
            title: "Photo Identification",
            description: "Take photos of food labels and get automatic copper analysis"
        ),
        PremiumFeature(
            icon: "chart.bar.fill",
            title: "Unlimited Food Logging",
            description: "Track all daily meals with no limits and view detailed history"
        ),
        PremiumFeature(
            icon: "bell.badge.fill",
            title: "Custom Alerts",
            description: "Get personalized notifications when approaching copper limits"
        ),
        PremiumFeature(
            icon: "sparkles",
            title: "AI Insights",
            description: "Receive intelligent recommendations based on your dog's health data"
        ),
        PremiumFeature(
            icon: "cloud.fill",
            title: "Cloud Sync",
            description: "Access your data across multiple devices with automatic backup"
        )
    ]

    // MARK: - Computed Properties
    var monthlyProduct: Product? {
        availableProducts.first { !($0.subscription?.subscriptionPeriod.unit == .year) }
    }

    var yearlyProduct: Product? {
        availableProducts.first { $0.subscription?.subscriptionPeriod.unit == .year }
    }

    var isLoading: Bool {
        purchaseState == .loading || purchaseState == .purchasing
    }

    // MARK: - Initialization
    init(subscriptionService: any SubscriptionService) {
        self.subscriptionService = subscriptionService

        // Observe service changes after initialization
        Task { [weak self] in
            await self?.observeServiceChanges()
        }
    }

    // MARK: - Public Methods
    func loadProducts() async {
        guard availableProducts.isEmpty else { return }

        do {
            purchaseState = .loading
            try await subscriptionService.loadProducts()
            availableProducts = subscriptionService.availableProducts
            purchaseState = .idle
        } catch {
            errorMessage = "Failed to load subscription plans. Please try again."
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func checkSubscriptionStatus() async {
        await subscriptionService.checkSubscriptionStatus()
        isPremium = subscriptionService.isPremium
    }

    func purchase(_ product: Product) async {
        do {
            purchaseState = .purchasing
            try await subscriptionService.purchase(product)
            isPremium = subscriptionService.isPremium

            if isPremium {
                purchaseState = .success
                // Auto-dismiss paywall after successful purchase
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showPaywall = false
                    self.purchaseState = .idle
                }
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            purchaseState = .loading
            try await subscriptionService.restorePurchases()
            isPremium = subscriptionService.isPremium

            if isPremium {
                purchaseState = .restored
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showPaywall = false
                    self.purchaseState = .idle
                }
            } else {
                errorMessage = "No previous purchases found."
                purchaseState = .idle
            }
        } catch {
            errorMessage = "Failed to restore purchases. Please try again."
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func presentPaywall(for featureName: String? = nil) {
        showPaywall = true
    }

    func dismissPaywall() {
        showPaywall = false
        errorMessage = nil
        purchaseState = .idle
    }

    func clearError() {
        errorMessage = nil
        if case .failed = purchaseState {
            purchaseState = .idle
        }
    }

    // MARK: - Private Methods
    private func observeServiceChanges() async {
        // Monitor subscription service for changes
        for await _ in NotificationCenter.default.notifications(named: .subscriptionStatusChanged) {
            await checkSubscriptionStatus()
        }
    }
}

// MARK: - Premium Feature Model
struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Notification Names
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

// MARK: - Preview Helper
extension SubscriptionViewModel {
    static var preview: SubscriptionViewModel {
        let mockService = SubscriptionServiceMock()
        return SubscriptionViewModel(subscriptionService: mockService)
    }

    static var premiumPreview: SubscriptionViewModel {
        let mockService = SubscriptionServiceMock()
        mockService.isPremium = true
        return SubscriptionViewModel(subscriptionService: mockService)
    }
}

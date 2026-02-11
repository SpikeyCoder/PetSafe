import SwiftUI
import StoreKit

// MARK: - Paywall View
/// Premium subscription paywall with product selection and purchase flow
struct PaywallView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    header
                    features
                    subscriptionPlans
                    restoreButton

                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                    }

                    if let successMessage = viewModel.purchaseState.successMessage {
                        successBanner(message: successMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        viewModel.dismissPaywall()
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await viewModel.loadProducts()
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Premium Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.orange100, Theme.Colors.orange50],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.Colors.orange600)
            }

            Text("Unlock Premium Features")
                .font(Theme.Typography.title)
                .multilineTextAlignment(.center)

            Text("Get the most out of PetSafe with unlimited tracking, photo identification, and personalized insights")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Features List
    private var features: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(viewModel.premiumFeatures) { feature in
                FeatureRow(feature: feature)
            }
        }
    }

    // MARK: - Subscription Plans
    private var subscriptionPlans: some View {
        VStack(spacing: Theme.Spacing.md) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, Theme.Spacing.xxl)
            } else if viewModel.availableProducts.isEmpty {
                // Debug view when no products load
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    
                    Text("Unable to Load Products")
                        .font(Theme.Typography.headline)
                    
                    Text("Make sure StoreKit Configuration is enabled in your scheme settings.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.loadProducts()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry Loading Products")
                        }
                        .font(Theme.Typography.subheadline.weight(.semibold))
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.orange600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
                    }
                }
                .padding(.vertical, Theme.Spacing.xxl)
            } else {
                if let yearlyProduct = viewModel.yearlyProduct {
                    PricingCard(
                        product: yearlyProduct,
                        isRecommended: true,
                        onSelect: {
                            Task {
                                await viewModel.purchase(yearlyProduct)
                            }
                        }
                    )
                }

                if let monthlyProduct = viewModel.monthlyProduct {
                    PricingCard(
                        product: monthlyProduct,
                        isRecommended: false,
                        onSelect: {
                            Task {
                                await viewModel.purchase(monthlyProduct)
                            }
                        }
                    )
                }
            }

            // Terms text
            Text("Cancel anytime. Auto-renews unless cancelled at least 24 hours before the end of the current period.")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.sm)
        }
    }

    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            Task {
                await viewModel.restorePurchases()
            }
        } label: {
            HStack {
                if case .loading = viewModel.purchaseState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.orange600))
                }
                Text("Restore Purchases")
            }
            .font(Theme.Typography.subheadline)
            .foregroundStyle(Theme.Colors.orange600)
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.Colors.dangerRed)
            Text(message)
                .font(Theme.Typography.caption)
            Spacer()
            Button {
                viewModel.clearError()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.red50)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Theme.Colors.red200, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    // MARK: - Success Banner
    private func successBanner(message: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.Colors.safeGreen)
            Text(message)
                .font(Theme.Typography.subheadline.weight(.semibold))
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.green50)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Theme.Colors.green200, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let feature: PremiumFeature

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundStyle(Theme.Colors.orange600)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(Theme.Typography.subheadline.weight(.semibold))
                Text(feature.description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Pricing Card
struct PricingCard: View {
    let product: Product
    let isRecommended: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: Theme.Spacing.md) {
                // Recommended badge
                if isRecommended {
                    Text("BEST VALUE")
                        .font(Theme.Typography.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.xxs)
                        .background(Theme.Colors.orange600)
                        .clipShape(Capsule())
                }

                // Pricing info
                VStack(spacing: 4) {
                    Text(product.displayName)
                        .font(Theme.Typography.headline)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(product.displayPrice)
                            .font(Theme.Typography.customTitle(28))
                            .fontWeight(.bold)
                        Text(product.displayPeriod)
                            .font(Theme.Typography.callout)
                            .foregroundStyle(.secondary)
                    }

                    if let savings = product.savingsText {
                        Text(savings)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.safeGreen)
                    }
                }

                // Select button
                Text("Select Plan")
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(
                        isRecommended ? Theme.Colors.orange600 : Color(.secondarySystemBackground)
                    )
                    .foregroundStyle(isRecommended ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }
            .padding(Theme.Spacing.lg)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(
                        isRecommended ? Theme.Colors.orange600 : Color.gray.opacity(0.3),
                        lineWidth: isRecommended ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .shadow(
                color: isRecommended ? Theme.Colors.orange600.opacity(0.2) : .clear,
                radius: Theme.Shadow.md,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews
#Preview("Paywall View") {
    PaywallView(viewModel: .preview)
}

#Preview("Premium User") {
    PaywallView(viewModel: .premiumPreview)
}

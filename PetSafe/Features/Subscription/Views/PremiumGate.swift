import SwiftUI

// MARK: - Premium Gate
/// Reusable component to gate features behind premium subscription
/// Shows locked content preview or allows access based on premium status
struct PremiumGate<Content: View, LockedContent: View>: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    let featureName: String
    let content: () -> Content
    let lockedContent: (() -> LockedContent)?

    init(
        viewModel: SubscriptionViewModel,
        featureName: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder lockedContent: @escaping () -> LockedContent
    ) {
        self.viewModel = viewModel
        self.featureName = featureName
        self.content = content
        self.lockedContent = lockedContent
    }

    init(
        viewModel: SubscriptionViewModel,
        featureName: String,
        @ViewBuilder content: @escaping () -> Content
    ) where LockedContent == DefaultLockedView {
        self.viewModel = viewModel
        self.featureName = featureName
        self.content = content
        self.lockedContent = nil
    }

    var body: some View {
        if viewModel.isPremium {
            content()
        } else {
            if let lockedContent = lockedContent {
                lockedContent()
            } else {
                DefaultLockedView(
                    featureName: featureName,
                    onUpgrade: {
                        viewModel.presentPaywall(for: featureName)
                    }
                )
            }
        }
    }
}

// MARK: - Default Locked View
struct DefaultLockedView: View {
    let featureName: String
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Lock icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.orangeCardBackground)
                    .frame(width: 60, height: 60)

                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Colors.orange600)
            }

            Text("Premium Feature")
                .font(Theme.Typography.headline)

            Text("Unlock \(featureName) with Premium")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                Text("Upgrade to Premium")
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(Theme.Colors.orange600)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.orangeCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Theme.Colors.orangeCardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Premium Badge Modifier
struct PremiumBadgeModifier: ViewModifier {
    @ObservedObject var viewModel: SubscriptionViewModel

    func body(content: Content) -> some View {
        HStack(spacing: 6) {
            content
            if !viewModel.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text("Premium")
                }
                .font(Theme.Typography.caption.weight(.semibold))
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xxs)
                .background(Theme.Colors.orange600)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            }
        }
    }
}

extension View {
    /// Adds a premium badge if the user is not premium
    func premiumBadge(viewModel: SubscriptionViewModel) -> some View {
        modifier(PremiumBadgeModifier(viewModel: viewModel))
    }

    /// Gates the entire view behind premium subscription
    func requiresPremium(
        viewModel: SubscriptionViewModel,
        featureName: String
    ) -> some View {
        PremiumGate(
            viewModel: viewModel,
            featureName: featureName,
            content: { self }
        )
    }
}

// MARK: - Premium Upgrade Banner
/// Dismissible banner encouraging users to upgrade to premium
struct PremiumUpgradeBanner: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @State private var isDismissed: Bool = false

    var body: some View {
        if !viewModel.isPremium && !isDismissed {
            HStack(alignment: .center, spacing: Theme.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Premium Features")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text("Get unlimited tracking, photo identification, and more")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: Theme.Spacing.md)

                Button {
                    viewModel.presentPaywall()
                } label: {
                    Text("Upgrade")
                        .font(Theme.Typography.subheadline.weight(.semibold))
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Colors.orange600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
                }

                Button {
                    withAnimation {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.orange600)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.orangeCardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(Theme.Colors.orangeCardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
    }
}

// MARK: - Previews
#Preview("Premium Gate - Locked") {
    VStack {
        PremiumGate(
            viewModel: .preview,
            featureName: "Barcode Scanner"
        ) {
            Text("Scanner content here")
        }
    }
    .padding()
}

#Preview("Premium Gate - Unlocked") {
    VStack {
        PremiumGate(
            viewModel: .premiumPreview,
            featureName: "Barcode Scanner"
        ) {
            Text("Scanner content here")
        }
    }
    .padding()
}

#Preview("Upgrade Banner") {
    VStack {
        PremiumUpgradeBanner(viewModel: .preview)
    }
    .padding()
}

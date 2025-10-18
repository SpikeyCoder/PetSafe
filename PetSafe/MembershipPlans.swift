import SwiftUI

struct PaymentMethod: Equatable {
    var id: String
    var type: String = "card"
    var last4: String
    var brand: String
    var holderName: String
}

struct MembershipPlans: View {
    let onPurchase: (_ plan: String, _ paymentMethod: PaymentMethod?) -> Void
    let onSkip: () -> Void
    let userProvider: String

    @State private var selectedPlan: String? = nil
    @State private var isProcessing = false

    struct Plan: Identifiable, Equatable {
        let id: String
        let name: String
        let price: String
        let period: String
        let description: String
        let badge: String?
        let badgeColor: Color
        let buttonText: String
        let variant: ButtonStyleVariant
        let features: [String]
        let limitations: [String]
        var displayOriginal: String? = nil
        var displayNote: String? = nil

        enum ButtonStyleVariant { case filled, outline }
        var _id: String { id }
        var _name: String { name }
        var _price: String { price }
        var _period: String { period }
        var _description: String { description }
        var _badge: String? { badge }
    }

    struct MembershipButtonStyle: ButtonStyle {
        let variant: Plan.ButtonStyleVariant
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(backgroundColor(isPressed: configuration.isPressed))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor(isPressed: configuration.isPressed), lineWidth: variant == .outline ? 1 : 0)
                )
                .foregroundStyle(foregroundColor())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }

        private func backgroundColor(isPressed: Bool) -> Color {
            switch variant {
            case .filled:
                return (isPressed ? Color.orange.opacity(0.8) : Color.orange)
            case .outline:
                return Color.clear
            }
        }

        private func borderColor(isPressed: Bool) -> Color {
            switch variant {
            case .filled:
                return Color.clear
            case .outline:
                return isPressed ? Color.orange.opacity(0.6) : Color.orange
            }
        }

        private func foregroundColor() -> Color {
            switch variant {
            case .filled:
                return Color.white
            case .outline:
                return Color.orange
            }
        }
    }

    var plans: [Plan] {
        [
            Plan(
                id: "premium-monthly",
                name: "Premium Monthly",
                price: "$7.99",
                period: "per month",
                description: "Full access with monthly billing",
                badge: "Most Popular",
                badgeColor: Color.orange.opacity(0.2),
                buttonText: "Subscribe Monthly",
                variant: .filled,
                features: [
                    "Unlimited food scanning",
                    "Photo food identification",
                    "Daily copper tracking",
                    "Breed-specific recommendations",
                    "Unlimited dog profiles",
                    "Advanced health analytics",
                    "Weekly health reports",
                    "Priority customer support",
                    "Data export & backup",
                    "Vet consultation scheduling",
                    "Premium food database access"
                ],
                limitations: []
            ),
            Plan(
                id: "premium-yearly",
                name: "Premium Yearly",
                price: "$79.99",
                period: "per year",
                description: "Save with annual billing",
                badge: "Best Value",
                badgeColor: Color.green.opacity(0.2),
                buttonText: "Subscribe Yearly",
                variant: .outline,
                features: [
                    "Everything in Premium Monthly",
                    "Annual health summary report",
                    "Dedicated account manager",
                    "Early access to new features",
                    "Extended vet partnership network"
                ],
                limitations: []
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.orange.opacity(0.2)).frame(width: 72, height: 72)
                            Image(systemName: "crown").foregroundStyle(Color.orange)
                        }
                        Text("Choose Your Plan").font(.title2.weight(.semibold))
                        Text("Start your journey to better pet health management.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    ForEach(plans) { plan in
                        planCard(plan)
                    }

                    VStack(spacing: 8) {
                        Button("Maybe later", action: onSkip)
                            .buttonStyle(.bordered)
                        Text("30-day money-back guarantee. Cancel anytime. By subscribing, you agree to our Terms of Service. PetSafe is for informational purposes only.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Membership")
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView("Processing your subscription...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    @ViewBuilder private func planCard(_ plan: Plan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(plan.name).font(.headline)
                Spacer()
                if let badge = plan.badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(plan.badgeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(plan.price).font(.title2.weight(.bold))
                Text("/\(plan.period)").foregroundStyle(.secondary)
            }
            Text(plan.description).font(.subheadline).foregroundStyle(.secondary)

            Button {
                subscribe(plan)
            } label: {
                HStack {
                    if selectedPlan == plan.id && isProcessing {
                        ProgressView()
                    }
                    Text(plan.buttonText).frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(MembershipButtonStyle(variant: plan.variant))
            .tint(.orange)

            VStack(alignment: .leading, spacing: 6) {
                Text("Included Features").font(.subheadline.weight(.semibold))
                ForEach(plan.features, id: \.self) { f in
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(f).font(.footnote)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func subscribe(_ plan: Plan) {
        selectedPlan = plan.id
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            onPurchase(plan.id, PaymentMethod(id: UUID().uuidString, last4: "4242", brand: "visa", holderName: "John Smith"))
        }
    }
}

#Preview {
    MembershipPlans(onPurchase: { plan, paymentMethod in
        print("Purchased plan: \(plan), payment method: \(String(describing: paymentMethod))")
    }, onSkip: {
        print("User skipped membership.")
    }, userProvider: "apple")
}

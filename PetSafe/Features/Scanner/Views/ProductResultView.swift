import SwiftUI

// MARK: - Product Result View
/// Displays scanned product information with copper analysis
struct ProductResultView: View {
    let product: ScannedProduct
    let onAddToLog: (Double) -> Void
    let onRescan: () -> Void

    @State private var amountText: String = ""
    @State private var showingAddSuccess = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, Theme.Spacing.sm)

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Product header
                        productHeader

                        // Copper analysis card
                        copperAnalysisCard

                        // Ingredients section
                        if !product.ingredients.isEmpty {
                            ingredientsSection
                        }

                        // Add to log section
                        addToLogSection

                        // Rescan button
                        rescanButton
                    }
                    .padding()
                }
            }
            .frame(maxHeight: geometry.size.height * 0.75)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.xl))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5)
        }
    }

    // MARK: - Product Header
    private var productHeader: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Safety icon
            ZStack {
                Circle()
                    .fill(product.safetyLevel.backgroundColor)
                    .frame(width: 60, height: 60)

                Image(systemName: product.safetyIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(product.safetyColor)
            }

            // Product name
            Text(product.name)
                .font(Theme.Typography.title)
                .multilineTextAlignment(.center)

            // Brand
            Text(product.brand)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

            // Badges
            if !product.badges.isEmpty {
                FlowWrapHStack(items: product.badges) { badge in
                    Text(badge)
                        .font(Theme.Typography.caption)
                        .badgeStyle(
                            backgroundColor: Theme.Colors.blue50,
                            foregroundColor: Theme.Colors.blue600
                        )
                }
            }

            // Barcode
            Text("Barcode: \(product.barcode)")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Copper Analysis Card
    private var copperAnalysisCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(product.safetyColor)
                Text("Copper Analysis")
                    .font(Theme.Typography.headline)
                Spacer()
            }

            // Safety status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety Level")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Image(systemName: product.safetyIcon)
                        Text(product.safetyText)
                    }
                    .font(Theme.Typography.headline)
                    .foregroundStyle(product.safetyColor)
                }
                Spacer()
            }

            Divider()

            // Copper content
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Copper Content")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.2f", product.copperMgPer100g))
                            .font(Theme.Typography.customTitle(32))
                            .fontWeight(.bold)
                        Text("mg / 100g")
                            .font(Theme.Typography.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Level")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    Text(product.copperLevelDescription)
                        .font(Theme.Typography.subheadline.weight(.semibold))
                        .foregroundStyle(product.safetyColor)
                }
            }

            // Estimation warning
            if product.isEstimated {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Theme.Colors.warningYellow)
                    Text("Estimated based on ingredients - actual values may vary")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.yellow50)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            }
        }
        .cardStyle(
            backgroundColor: product.safetyLevel.backgroundColor,
            borderColor: product.safetyLevel.borderColor
        )
    }

    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "list.bullet")
                Text("Ingredients")
                    .font(Theme.Typography.headline)
                Spacer()
            }

            Text(product.ingredients.joined(separator: ", "))
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    // MARK: - Add to Log Section
    private var addToLogSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.Colors.orange600)
                Text("Add to Food Log")
                    .font(Theme.Typography.headline)
                Spacer()
            }

            HStack(spacing: Theme.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount (grams)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g., 150", text: $amountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                if let amount = Double(amountText), amount > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Copper")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                        let totalCopper = (product.copperMgPer100g * amount) / 100.0
                        Text(String(format: "%.2f mg", totalCopper))
                            .font(Theme.Typography.subheadline.weight(.semibold))
                            .foregroundStyle(copperColorForAmount(totalCopper))
                    }
                    .padding(.top, 20)
                }
            }

            Button {
                if let amount = Double(amountText), amount > 0 {
                    onAddToLog(amount)
                    showingAddSuccess = true
                    // Reset after short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showingAddSuccess = false
                    }
                }
            } label: {
                HStack {
                    if showingAddSuccess {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Added!")
                    } else {
                        Image(systemName: "plus")
                        Text("Add to Log")
                    }
                }
                .font(Theme.Typography.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    showingAddSuccess ? Theme.Colors.safeGreen : Theme.Colors.orange600
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }
            .disabled(amountText.isEmpty || Double(amountText) == nil || Double(amountText)! <= 0)
            .animation(.easeInOut, value: showingAddSuccess)
        }
        .cardStyle()
    }

    // MARK: - Rescan Button
    private var rescanButton: some View {
        Button {
            onRescan()
        } label: {
            HStack {
                Image(systemName: "camera.viewfinder")
                Text("Scan Another Product")
            }
            .font(Theme.Typography.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
    }

    // MARK: - Helper Methods
    private func copperColorForAmount(_ amount: Double) -> Color {
        if amount < 0.5 {
            return Theme.Colors.safeGreen
        } else if amount < 1.5 {
            return Theme.Colors.warningYellow
        } else {
            return Theme.Colors.dangerRed
        }
    }
}

// MARK: - Preview
#Preview("Product Result - Safe") {
    ProductResultView(
        product: ScannedProduct(
            barcode: "1234567890",
            name: "Low-Copper Dog Kibble",
            brand: "Hill's Science Diet",
            copperMgPer100g: 0.8,
            safetyLevel: .safe,
            badges: ["Low Cu", "Dry Food"],
            ingredients: ["chicken", "rice", "vitamins"],
            imageUrl: nil,
            isEstimated: false
        ),
        onAddToLog: { _ in },
        onRescan: { }
    )
}

#Preview("Product Result - Danger") {
    ProductResultView(
        product: ScannedProduct(
            barcode: "0987654321",
            name: "Beef & Liver Mix",
            brand: "Premium Pet Food",
            copperMgPer100g: 4.2,
            safetyLevel: .danger,
            badges: ["High Cu", "Wet Food", "Organ Meat"],
            ingredients: ["beef", "liver", "minerals"],
            imageUrl: nil,
            isEstimated: true
        ),
        onAddToLog: { _ in },
        onRescan: { }
    )
}

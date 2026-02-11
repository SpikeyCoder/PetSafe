import SwiftUI

// Simple model matching your web structure
struct MockFoodEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let brand: String
    let amount: Double // grams
    let copperContent: Double // mg per 100g
    let timestamp: Date
    let limitedIngredient: Bool
}

struct ContentView: View {
    // App state
    @State private var hasActiveSubscription = false
    @State private var showPremiumGate = false
    @State private var premiumFeatureName = ""

    // Mock data
    @State private var dogName: String = "Max"
    @State private var dailyCopperLimit: Double = 5.0
    @State private var entries: [MockFoodEntry] = []

    var currentCopper: Double {
        entries.reduce(0) { partial, e in
            partial + (e.copperContent * e.amount) / 100.0
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Upgrade banner for free users
                    if !hasActiveSubscription {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unlock Premium Features")
                                    .font(.headline)
                                    .foregroundStyle(Color.orange900)
                                Text("Get unlimited food tracking, photo identification, and more")
                                    .font(.caption)
                                    .foregroundStyle(Color.orange700)
                            }
                            Spacer(minLength: 12)
                            Button {
                                premiumFeatureName = "Premium"
                                showPremiumGate = true
                            } label: {
                                Text("Upgrade")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange600)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(12)
                        .background(
                            LinearGradient(colors: [Color.orange100, Color.orange50], startPoint: .leading, endPoint: .trailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange200, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }

                    // Dog profile summary (lightweight)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "shield.checkerboard")
                                .foregroundStyle(Color.blue600)
                            Text("PetSafe")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.bottom, 4)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dogName)
                                    .font(.title3.weight(.semibold))
                                Text("Daily Copper Limit: \(dailyCopperLimit, specifier: "%.1f")mg")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.blue50)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue200, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Dashboard card
                    DashboardCardView(currentCopper: currentCopper, copperLimit: dailyCopperLimit, dogName: dogName)
                        .padding(.horizontal)

                    // Scanner section (mocked actions)
                    FoodScannerSection(isPremium: hasActiveSubscription) { featureName in
                        premiumFeatureName = featureName
                        showPremiumGate = true
                    } onAddFood: { name, brand, copperPer100g, amount, limited in
                        // Gate logging behind premium
                        guard hasActiveSubscription else {
                            premiumFeatureName = "Food Logging"
                            showPremiumGate = true
                            return
                        }
                        let new = MockFoodEntry(
                            id: UUID().uuidString,
                            name: name,
                            brand: brand,
                            amount: amount,
                            copperContent: copperPer100g,
                            timestamp: Date(),
                            limitedIngredient: limited
                        )
                        entries.append(new)
                    }
                    .padding(.horizontal)

                    // Today's Log
                    TodaysLogSection(entries: entries, totalCopper: currentCopper, isPremium: hasActiveSubscription) { id in
                        entries.removeAll { $0.id == id }
                    } onRequestPremium: { feature in
                        premiumFeatureName = feature
                        showPremiumGate = true
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showPremiumGate) {
                PremiumGateSheet(featureName: premiumFeatureName) {
                    // Upgrade: simulate purchase and unlock features
                    hasActiveSubscription = true
                    showPremiumGate = false
                } onClose: {
                    showPremiumGate = false
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - Premium Gate Sheet
struct PremiumGateSheet: View {
    let featureName: String
    let onUpgrade: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle().fill(LinearGradient(colors: [Color.orange100, Color.orange50], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 88, height: 88)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color.orange700)
                        }
                        Text("Unlock \(featureName)")
                            .font(.title2.weight(.semibold))
                        Text("This feature requires a Premium subscription")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        benefitRow(text: "Advanced photo food identification")
                        benefitRow(text: "Unlimited food logging and tracking")
                        benefitRow(text: "Breed-specific risk assessments")
                        benefitRow(text: "Personalized health recommendations")
                        benefitRow(text: "Daily intake alerts and notifications")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Color.orange700)
                            Text("Premium Subscription")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.orange800)
                        }
                        Text("Subscribe to unlock all premium features. Cancel anytime from your account settings.")
                            .font(.caption)
                            .foregroundStyle(Color.orange700)
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [Color.orange100, Color.orange50], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange200))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(spacing: 10) {
                        Button(action: onUpgrade) {
                            Text("Upgrade to Premium")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange600)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Button(action: onClose) {
                            Text("Maybe Later")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Premium")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close", action: onClose) } }
        }
    }

    @ViewBuilder private func benefitRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.green600)
            Text(text).font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - Dashboard Card
struct DashboardCardView: View {
    let currentCopper: Double
    let copperLimit: Double
    let dogName: String

    var percentage: Double { min(max(currentCopper / max(copperLimit, 0.001) * 100.0, 0), 100) }

    var status: (text: String, color: Color, bg: Color, border: Color, bar: Color) {
        if percentage < 70 { return ("Safe", .green600, .green50, .green200, .green500) }
        if percentage < 90 { return ("Caution", .yellow600, .yellow50, .yellow200, .yellow500) }
        return ("Danger", .red600, .red50, .red200, .red500)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(dogName)'s Copper Today")
                    .font(.headline)
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: status.text == "Safe" ? "checkmark.circle" : (status.text == "Caution" ? "exclamationmark.triangle" : "xmark.octagon"))
                        .foregroundStyle(status.color)
                    Text(status.text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(status.color.opacity(0.4)))
                }
            }

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(currentCopper, specifier: "%.1f")")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(status.color)
                    Text("/\(copperLimit, specifier: "%.2f")mg")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Text("\(max(copperLimit - currentCopper, 0), specifier: "%.1f")mg remaining")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                HStack {
                    Text("Daily Limit")
                    Spacer()
                    Text("\(percentage, specifier: "%.0f")%")
                }
                .font(.caption)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.12)).frame(height: 10)
                    Capsule().fill(status.bar).frame(width: max(0, percentage/100.0) * UIScreen.main.bounds.width * 0.8, height: 10)
                        .animation(.easeInOut(duration: 0.35), value: percentage)
                }
            }
        }
        .padding()
        .background(status.bg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(status.border))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Food Scanner (mock)
struct FoodScannerSection: View {
    let isPremium: Bool
    let onRequestPremium: (String) -> Void
    let onAddFood: (_ name: String, _ brand: String, _ copperPer100g: Double, _ amount: Double, _ limitedIngredient: Bool) -> Void

    @State private var amountText: String = ""
    @State private var selectedFood: (name: String, brand: String, copper: Double, limited: Bool)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "camera")
                Text("Photo Identification")
                    .font(.headline)
                Spacer()
                if !isPremium {
                    Text("Premium")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            HStack(spacing: 10) {
                Button {
                    isPremium ? simulateIdentify() : onRequestPremium("Photo Identification")
                } label: {
                    Label(isPremium ? "Take Photo" : "Take Photo (Premium)", systemImage: isPremium ? "camera" : "lock.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isPremium ? simulateBarcode() : onRequestPremium("Barcode Scanner")
                } label: {
                    Label(isPremium ? "Scan Barcode" : "Scan Barcode (Premium)", systemImage: isPremium ? "barcode.viewfinder" : "lock.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if let food = selectedFood {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(food.name)
                            .font(.subheadline.weight(.semibold))
                        if food.limited {
                            Text("LI")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
                        }
                        Spacer()
                    }
                    Text(food.brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("Copper: \(food.copper, specifier: "%.1f")mg / 100g")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue50)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue200))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        TextField("Amount (g)", text: $amountText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            if let amount = Double(amountText) {
                                onAddFood(food.name, food.brand, food.copper, amount, food.limited)
                                selectedFood = nil
                                amountText = ""
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(Double(amountText) == nil)
                    }
                }
                .padding()
                .background(Color.blue50)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue200))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func simulateIdentify() {
        // Mock a random food selection
        let foods: [(String, String, Double, Bool)] = [
            ("Senior Dog Food", "Hill's Science Diet", 1.2, false),
            ("Limited Ingredient Duck", "Blue Buffalo Basics", 0.8, true),
            ("Grain-Free Salmon", "Wellness CORE", 2.1, false),
            ("Liver Treats", "Zuke's", 8.5, false)
        ]
        if let pick = foods.randomElement() {
            selectedFood = (pick.0, pick.1, pick.2, pick.3)
        }
    }

    private func simulateBarcode() {
        simulateIdentify()
    }
}

// MARK: - Today's Log
struct TodaysLogSection: View {
    let entries: [MockFoodEntry]
    let totalCopper: Double
    let isPremium: Bool
    let onRemove: (String) -> Void
    let onRequestPremium: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                Text("Today's Food Log")
                    .font(.headline)
                Spacer()
                if !isPremium {
                    Label("Premium", systemImage: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange600)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            if entries.isEmpty {
                if isPremium {
                    VStack(spacing: 6) {
                        Text("No foods logged today")
                            .foregroundStyle(.secondary)
                        Text("Use the scanner or search to add foods")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill").font(.system(size: 32)).foregroundStyle(Color.orange600)
                        Text("Premium Feature").font(.headline)
                        Text("Track your dog's daily food intake and copper consumption with unlimited logging")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        Button {
                            onRequestPremium("Food Logging")
                        } label: {
                            Text("Unlock Food Logging").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.orange600)
                    }
                    .padding()
                    .background(Color.orange50.opacity(0.3))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange200))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(entries) { e in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(e.name).font(.subheadline.weight(.semibold))
                                    if e.limitedIngredient {
                                        Text("LI")
                                            .font(.caption2.weight(.bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
                                    }
                                }
                                Text(e.brand).font(.caption).foregroundStyle(.secondary)
                                HStack(spacing: 12) {
                                    Text("\(e.amount, specifier: "%.0f")g").font(.caption).foregroundStyle(.secondary)
                                    let copperFromEntry = (e.copperContent * e.amount)/100.0
                                    Text("\(copperFromEntry, specifier: "%.1f")mg copper")
                                        .font(.caption)
                                        .foregroundStyle(copperColor(copperFromEntry))
                                    Text(e.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button(role: .destructive) {
                                onRemove(e.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Divider().padding(.vertical, 4)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Items").font(.caption).foregroundStyle(.secondary)
                        Text("\(entries.count)")
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Total Weight").font(.caption).foregroundStyle(.secondary)
                        let totalWeight = entries.reduce(0) { $0 + $1.amount }
                        Text("\(totalWeight, specifier: "%.0f")g")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total").font(.caption).foregroundStyle(.secondary)
                        Text("\(totalCopper, specifier: "%.1f")mg Cu")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func copperColor(_ value: Double) -> Color {
        if value < 0.5 { return .green600 }
        if value < 1.0 { return .yellow600 }
        return .red600
    }
}

// MARK: - Color helpers (approximate Tailwind-like palette)
extension Color {
    static let orange50 = Color(red: 1.0, green: 0.973, blue: 0.941)
    static let orange100 = Color(red: 1.0, green: 0.945, blue: 0.89)
    static let orange200 = Color(red: 0.996, green: 0.894, blue: 0.78)
    static let orange600 = Color(red: 0.89, green: 0.38, blue: 0.18)
    static let orange700 = Color(red: 0.78, green: 0.29, blue: 0.12)
    static let orange800 = Color(red: 0.64, green: 0.22, blue: 0.09)
    static let orange900 = Color(red: 0.55, green: 0.18, blue: 0.05)

    static let blue50 = Color(red: 0.949, green: 0.965, blue: 0.996)
    static let blue200 = Color(red: 0.8, green: 0.86, blue: 0.98)
    static let blue600 = Color(red: 0.15, green: 0.35, blue: 0.85)

    static let green50 = Color(red: 0.941, green: 0.973, blue: 0.953)
    static let green200 = Color(red: 0.8, green: 0.92, blue: 0.83)
    static let green500 = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let green600 = Color(red: 0.12, green: 0.6, blue: 0.3)

    static let yellow50 = Color(red: 1.0, green: 0.98, blue: 0.9)
    static let yellow200 = Color(red: 0.98, green: 0.9, blue: 0.6)
    static let yellow500 = Color(red: 0.95, green: 0.75, blue: 0.2)
    static let yellow600 = Color(red: 0.85, green: 0.65, blue: 0.1)

    static let red50 = Color(red: 1.0, green: 0.94, blue: 0.94)
    static let red200 = Color(red: 0.98, green: 0.8, blue: 0.8)
    static let red500 = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let red600 = Color(red: 0.8, green: 0.1, blue: 0.1)
}

#Preview {
    ContentView()
}

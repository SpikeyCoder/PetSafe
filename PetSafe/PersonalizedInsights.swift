import SwiftUI

struct PersonalizedInsights: View {
    let onboardingData: OnboardingData
    let riskLevel: String // "high" | "medium" | "low"
    let currentCopper: Double
    let copperLimit: Double

    @State private var recsState: LoadState<[FoodRecommendation]> = .idle
    @State private var selectedTab: TopTab = .home
    @State private var isPremium: Bool = false // TODO: Inject real premium status

    // Dependency points (replace mocks with real implementations)
    var openFoodFacts: OpenFoodFactsService = OpenFoodFactsMock()
    var usdaService: USDAService = USDAMock()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                topTabs

                switch selectedTab {
                case .home:
                    upgradeBanner
                    profileSummaryCard
                    copperTodayCard
                    insightsSection
                case .scan:
                    scanSection
                case .log:
                    logSection
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
        }
    }

    private var topTabs: some View {
        HStack(spacing: 8) {
            segmentButton(.home, systemImage: "house")
            segmentButton(.scan, systemImage: "barcode.viewfinder")
            segmentButton(.log, systemImage: "clock.arrow.circlepath")
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func segmentButton(_ tab: TopTab, systemImage: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(tab.rawValue)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if selectedTab == tab { Color.accentColor.opacity(0.12) } else { Color.clear }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var upgradeBanner: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Unlock Premium Features")
                    .font(.headline)
                    .foregroundStyle(Color.orange900)
                Text("Get unlimited tracking, photo identification, and more")
                    .font(.caption)
                    .foregroundStyle(Color.orange700)
            }
            Spacer(minLength: 12)
            Button {
                // Hook up to premium flow if needed
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
    }

    private var profileSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pawprint.circle.fill")
                    .foregroundStyle(Color.blue600)
                Text(onboardingData.dogName.isEmpty ? "Your Dog" : onboardingData.dogName)
                    .font(.headline)
                Spacer()
            }
            Grid(alignment: .leading) {
                GridRow { Text("Breed").foregroundStyle(.secondary); Text(onboardingData.breed.isEmpty ? "—" : onboardingData.breed) }
                GridRow { Text("Age").foregroundStyle(.secondary); Text("\(onboardingData.age) yrs") }
                GridRow { Text("Weight").foregroundStyle(.secondary); Text("\(onboardingData.weight) lbs") }
                GridRow { Text("Daily Limit").foregroundStyle(.secondary); Text("\(copperLimit, specifier: "%.2f") mg Cu") }
                GridRow { Text("Risk").foregroundStyle(.secondary); Text(riskLevel.capitalized).foregroundStyle(colorForRisk()) }
            }
        }
        .padding()
        .background(Color.blue50)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue200))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var copperTodayCard: some View {
        let percentage = min(max(currentCopper / max(copperLimit, 0.001) * 100.0, 0), 100)
        let status = statusFor(percentage: percentage)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(onboardingData.dogName.isEmpty ? "Dog" : onboardingData.dogName)'s Copper Today")
                    .font(.headline)
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: status.icon).foregroundStyle(status.color)
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
                GeometryReader { proxy in
                    let availableWidth = proxy.size.width
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.12)).frame(height: 10)
                        Capsule()
                            .fill(status.bar)
                            .frame(width: max(0, min(1.0, percentage/100.0)) * availableWidth, height: 10)
                    }
                }
                .frame(height: 10)
            }

            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .foregroundStyle(status.color)
                Text(recommendationText())
                    .font(.footnote)
            }
        }
        .padding()
        .background(status.bg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(status.border))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var scanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "barcode.viewfinder").foregroundStyle(.blue)
                Text("Scan a Barcode").font(.headline)
                Spacer()
                if !isPremium {
                    Text("Premium")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            if isPremium {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Point your camera at a barcode to analyze copper safety.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button {
                        // TODO: Hook into real scanner flow
                    } label: {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Start Scanning")
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Non-premium preview: show pre-populated mock results (from current card state)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview: Example scan results")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    foodRecommendationsCard
                    Button {
                        // TODO: Present paywall
                    } label: {
                        Text("Upgrade to unlock scanning")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange600)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath").foregroundStyle(.purple)
                Text("Food Log").font(.headline)
                Spacer()
                if !isPremium {
                    Text("Premium")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            if isPremium {
                // Simple mock log list; replace with real data source
                let items = [
                    ("Chicken & Rice (homemade)", "0.42 mg Cu", "Today"),
                    ("Safe: Low-Copper Kibble", "—", "Yesterday"),
                    ("Beef & Liver Mix", "High Cu", "2 days ago")
                ]
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<items.count, id: \.self) { i in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(items[i].0).font(.subheadline.weight(.semibold))
                                Text(items[i].2).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(items[i].1)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview: Recent items")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    // Reuse recommendations as a stand-in for recent log entries
                    foodRecommendationsCard
                    Button {
                        // TODO: Present paywall
                    } label: {
                        Text("Upgrade to unlock food logging")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange600)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights for \(onboardingData.dogName.isEmpty ? "your dog" : onboardingData.dogName)")
                .font(.headline)
                .padding(.horizontal, 2)

            personalizedMessageCard

            healthOverviewCard

            foodRecommendationsCard

            tipsCard
        }
    }

    private var personalizedMessageCard: some View {
        let message = getPersonalizedMessage()
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: message.icon).foregroundStyle(message.color)
                Text(message.title).font(.headline)
            }
            Text(message.message).font(.subheadline)
            HStack(spacing: 8) {
                Text(message.focus)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(message.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Priority: \(message.priority)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(message.bg)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(message.border))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var healthOverviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg").foregroundStyle(.blue)
                Text("Health Overview").font(.headline)
            }
            Grid(alignment: .leading) {
                GridRow { Text("Age").foregroundStyle(.secondary); Text("\(onboardingData.age) yrs") }
                GridRow { Text("Weight").foregroundStyle(.secondary); Text("\(onboardingData.weight) lbs") }
                GridRow { Text("Risk").foregroundStyle(.secondary); Text(riskLevel.capitalized).foregroundStyle(colorForRisk()) }
                GridRow { Text("Daily Limit").foregroundStyle(.secondary); Text("\(copperLimit, specifier: "%.2f") mg Cu") }
                GridRow { Text("Current").foregroundStyle(.secondary); Text("\(currentCopper, specifier: "%.2f") mg Cu") }
            }
            if onboardingData.healthConditions.filter({ $0 != "None of the above" }).count > 0 {
                Divider()
                Text("Health Conditions").font(.subheadline.weight(.semibold))
                FlowWrapHStack(items: Array(onboardingData.healthConditions.filter { $0 != "None of the above" })) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }
            }
            if onboardingData.dietaryRestrictions.filter({ $0 != "No specific restrictions" }).count > 0 {
                Divider()
                Text("Diet Type").font(.subheadline.weight(.semibold))
                FlowWrapHStack(items: Array(onboardingData.dietaryRestrictions.filter { $0 != "No specific restrictions" }.prefix(3))) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var foodRecommendationsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.circle.fill").foregroundStyle(.green)
                Text("Food Recommendations for \(onboardingData.dogName.isEmpty ? "your dog" : onboardingData.dogName)")
                    .font(.headline)
                Spacer()
                switch recsState {
                case .loading:
                    ProgressView().scaleEffect(0.8)
                default:
                    EmptyView()
                }
            }

            switch recsState {
            case .idle:
                Text("")
                    .task { await loadRecommendations() }
            case .loading:
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView("Fetching recommendations…")
                        .progressViewStyle(.linear)
                }
                .padding(.vertical, 4)
            case .failed(let message):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            case .loaded(let recs):
                if recs.isEmpty {
                    Text("No recommendations yet. Start scanning foods to get personalized suggestions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(recs.indices, id: \.self) { i in
                        let rec = recs[i]
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(rec.name)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                HStack(spacing: 6) {
                                    Text(rec.confidence.rawValue)
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(rec.confidence.badgeColor.opacity(0.15))
                                        .foregroundStyle(rec.confidence.badgeColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    Text(rec.safety.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(rec.safety.badgeColor.opacity(0.15))
                                        .foregroundStyle(rec.safety.badgeColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            // Badges row
                            FlowWrapHStack(items: rec.badges) { badge in
                                Text(badge)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.25)))
                            }
                            if let note = rec.note {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @MainActor
    private func loadRecommendations() async {
        if case .loading = recsState { return }
        recsState = .loading
        do {
            // Example flow:
            // 1) Pull a few recent barcodes (stubbed here) and look up via OpenFoodFacts
            let sampleBarcodes = ["0766781234567", "0001112223334"]
            let products = try await openFoodFacts.lookup(barcodes: sampleBarcodes)

            // 2) Build a couple of USDA ingredient-based recipe estimates
            let recipe = try await usdaService.estimateCopperForRecipe(ingredients: [
                USDAIngredient(name: "Chicken breast, raw", grams: 100),
                USDAIngredient(name: "White rice, cooked", grams: 120)
            ])

            // 3) Map to FoodRecommendation list with safety heuristics
            var combined: [FoodRecommendation] = []
            for p in products {
                let safety = safetyFor(ingredients: p.ingredients)
                let note = p.copperMgPer100g != nil ? "Contains copper: \(String(format: "%.2f", p.copperMgPer100g!)) mg/100g" : "Estimated from ingredients"
                combined.append(FoodRecommendation(
                    name: p.name,
                    safety: safety,
                    badges: p.badges,
                    note: note,
                    confidence: p.copperMgPer100g != nil ? .verified : .estimated
                ))
            }
            combined.append(FoodRecommendation(
                name: recipe.title,
                safety: recipe.copperMgPerServing <= 0.5 ? .good : (recipe.copperMgPerServing <= 1.0 ? .caution : .avoid),
                badges: ["Recipe", "USDA", "Est."],
                note: "Copper per serving: \(String(format: "%.2f", recipe.copperMgPerServing)) mg",
                confidence: .estimated
            ))

            recsState = .loaded(combined)
        } catch {
            recsState = .failed("Could not load recommendations. Please try again.")
        }
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundStyle(.yellow)
                Text("Tips for \(onboardingData.dogName)").font(.headline)
            }
            let tips = Array(getPersonalizedTips().prefix(4))
            ForEach(tips.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundStyle(.secondary)
                    Text(tips[i]).font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statusFor(percentage: Double) -> (text: String, color: Color, bg: Color, border: Color, bar: Color, icon: String) {
        if percentage < 70 { return ("Safe", .green600, .green50, .green200, .green500, "checkmark.circle") }
        if percentage < 90 { return ("Caution", .yellow600, .yellow50, .yellow200, .yellow500, "exclamationmark.triangle") }
        return ("High", .red600, .red50, .red200, .red500, "xmark.octagon")
    }

    private func recommendationText() -> String {
        if onboardingData.vetRecommendations.contains("Regular liver function tests") {
            return "Regular vet check-ups recommended for ongoing copper management"
        }
        if onboardingData.healthConditions.contains("Copper Storage Disease") {
            return "Tip: Low-copper diet and regular monitoring"
        }
        return "Tip: Try a low-copper food or scan a barcode"
    }

    private func colorForRisk() -> Color {
        switch riskLevel.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }

    private func getPersonalizedMessage() -> (title: String, message: String, color: Color, bg: Color, border: Color, icon: String, focus: String, priority: String) {
        if onboardingData.healthConditions.contains("Copper Storage Disease") {
            return ("\(onboardingData.dogName)'s Copper Management",
                    "With confirmed copper storage disease, maintaining strict copper limits is crucial for liver health.",
                    .red, Color.red.opacity(0.1), Color.red.opacity(0.2),
                    "exclamationmark.triangle.fill", "Copper Prevention", "High")
        }
        if onboardingData.healthConditions.contains("Liver Disease") {
            return ("Supporting \(onboardingData.dogName)'s Liver Health",
                    "Monitoring copper intake is especially important for dogs with liver conditions.",
                    .orange, Color.orange.opacity(0.1), Color.orange.opacity(0.2),
                    "heart.fill", "Liver Health", "High")
        }
        if riskLevel.lowercased() == "high" {
            return ("\(onboardingData.breed) Care Plan",
                    "\(onboardingData.breed)s are at higher risk for copper accumulation. You're doing great by monitoring!",
                    .blue, Color.blue.opacity(0.1), Color.blue.opacity(0.2),
                    "shield.fill", "Breed Care", "Medium")
        }
        return ("\(onboardingData.dogName)'s Health Journey",
                "Keep up the excellent monitoring to maintain optimal health!",
                .green, Color.green.opacity(0.1), Color.green.opacity(0.2),
                "checkmark.circle.fill", "General Wellness", "Low")
    }

    private func getPersonalizedTips() -> [String] {
        var tips: [String] = []
        if onboardingData.dietaryRestrictions.contains("Limited ingredient diet") {
            tips.append("✓ Limited ingredient diets naturally reduce copper exposure")
        }
        if onboardingData.dietaryRestrictions.contains("Raw food diet") {
            tips.append("⚠️ Raw diets: Monitor organ meat portions carefully")
        }
        if onboardingData.dietaryRestrictions.contains("Low-copper diet") {
            tips.append("🎯 Perfect! Low-copper diets are ideal for management")
        }
        if onboardingData.healthConditions.contains("Copper Storage Disease") {
            tips.append("🏥 Work closely with your vet for regular monitoring")
        }
        if onboardingData.age > 8 {
            tips.append("👴 Senior dogs may need adjusted copper limits")
        }
        if onboardingData.vetRecommendations.contains("Monitor copper intake") {
            tips.append("👨‍⚕️ Following vet's copper monitoring recommendation")
        }
        if onboardingData.vetRecommendations.contains("Avoid high-copper foods") {
            tips.append("🚫 Avoiding liver, shellfish, and nuts as recommended")
        }
        if tips.isEmpty {
            tips = [
                "📱 Regular tracking helps identify patterns",
                "🥘 Consistent feeding schedules aid monitoring",
                "📊 Weekly reviews help optimize diet plans"
            ]
        }
        return tips
    }
    
    private enum LoadState<Value> {
        case idle
        case loading
        case loaded(Value)
        case failed(String)
    }
    
    private enum FoodSafety: String { case good = "Good", caution = "Caution", avoid = "Avoid"
        var badgeColor: Color {
            switch self {
            case .good: return .green600
            case .caution: return .yellow600
            case .avoid: return .red600
            }
        }
    }

    private enum Confidence: String { case verified = "Verified", estimated = "Estimated"
        var badgeColor: Color { self == .verified ? .blue600 : .gray }
    }

    private enum TopTab: String, CaseIterable { case home = "Home", scan = "Scan", log = "Log" }

    private struct FoodRecommendation: Identifiable {
        let id = UUID()
        let name: String
        let safety: FoodSafety
        let badges: [String]
        let note: String?
        let confidence: Confidence
    }

    private func getFoodRecommendations() -> [FoodRecommendation] {
        var results: [FoodRecommendation] = []

        // Simple, local logic based on risk level and dietary preferences
        let isHighRisk = riskLevel.lowercased() == "high" || onboardingData.healthConditions.contains("Copper Storage Disease")
        let prefersLowCopper = onboardingData.dietaryRestrictions.contains("Low-copper diet")

        if prefersLowCopper || isHighRisk {
            results.append(FoodRecommendation(
                name: "Safe: Low-Copper Kibble",
                safety: .good,
                badges: ["Dry", "Kibble", "Low Cu", "Grain-free"],
                note: "Balanced option with reduced copper content",
                confidence: .estimated
            ))
            results.append(FoodRecommendation(
                name: "Turkey & Rice Formula",
                safety: .caution,
                badges: ["Canned", "Poultry", "Moderate Cu"],
                note: "Use in moderation; monitor daily copper total",
                confidence: .estimated
            ))
            results.append(FoodRecommendation(
                name: "Beef & Liver Mix",
                safety: .avoid,
                badges: ["Wet", "Beef", "Liver", "High Cu"],
                note: "Avoid due to organ meat’s high copper content",
                confidence: .estimated
            ))
        } else {
            results.append(FoodRecommendation(
                name: "Chicken & Oatmeal",
                safety: .good,
                badges: ["Dry", "Chicken", "Balanced"],
                note: "Good everyday choice",
                confidence: .estimated
            ))
            results.append(FoodRecommendation(
                name: "Salmon Stew",
                safety: .caution,
                badges: ["Wet", "Fish", "Omega-3"],
                note: "Fish can add copper; track servings",
                confidence: .estimated
            ))
        }

        return results
    }

    private func safetyFor(ingredients: [String]) -> FoodSafety {
        let lower = ingredients.map { $0.lowercased() }
        if lower.contains(where: { $0.contains("liver") || $0.contains("organ") || $0.contains("shellfish") }) {
            return .avoid
        }
        if lower.contains(where: { $0.contains("fish") || $0.contains("salmon") || $0.contains("by-product") }) {
            return .caution
        }
        return .good
    }
}

// MARK: - Data Services (stubs)
protocol OpenFoodFactsService {
    func lookup(barcodes: [String]) async throws -> [OFFProduct]
}

struct OFFProduct {
    let barcode: String
    let name: String
    let ingredients: [String]
    let copperMgPer100g: Double? // Often nil; OFF rarely has this
    let badges: [String]
}

struct OpenFoodFactsMock: OpenFoodFactsService {
    func lookup(barcodes: [String]) async throws -> [OFFProduct] {
        // Stubbed examples
        return [
            OFFProduct(barcode: barcodes.first ?? "", name: "Safe: Low-Copper Kibble", ingredients: ["chicken", "rice", "vitamins"], copperMgPer100g: nil, badges: ["Dry", "Kibble", "Low Cu"]),
            OFFProduct(barcode: barcodes.dropFirst().first ?? "", name: "Beef & Liver Mix", ingredients: ["beef", "liver", "minerals"], copperMgPer100g: nil, badges: ["Wet", "Beef", "Liver"])
        ]
    }
}

protocol USDAService {
    func estimateCopperForRecipe(ingredients: [USDAIngredient]) async throws -> USDARecipeEstimate
}

struct USDAIngredient {
    let name: String
    let grams: Double
}

struct USDARecipeEstimate {
    let title: String
    let copperMgPerServing: Double
}

struct USDAMock: USDAService {
    func estimateCopperForRecipe(ingredients: [USDAIngredient]) async throws -> USDARecipeEstimate {
        // Very rough estimate: pretend ingredients contribute small copper amounts
        let copper = ingredients.reduce(0.0) { partial, ing in
            partial + (ing.name.lowercased().contains("liver") ? 1.5 : 0.05) * (ing.grams / 100.0)
        }
        return USDARecipeEstimate(title: "Chicken & Rice (USDA est.)", copperMgPerServing: copper)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                // move to next line
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.minX + maxWidth {
                // wrap to next line
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// Convenience wrapper to mimic the old API
struct FlowWrapHStack<Content: View, T: Hashable>: View {
    let items: [T]
    let spacing: CGFloat
    let content: (T) -> Content
    
    init(items: [T], spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

#Preview {
    PersonalizedInsights(
        onboardingData: OnboardingData(
            dogName: "Max",
            breed: "Labrador Retriever",
            age: 7,
            weight: 65,
            healthConditions: ["Copper Storage Disease"],
            dietaryRestrictions: ["Low-copper diet"],
            primaryConcerns: ["Copper toxicity prevention"],
            vetRecommendations: ["Monitor copper intake"]
        ),
        riskLevel: "high",
        currentCopper: 1.2,
        copperLimit: 5.0
    )
}

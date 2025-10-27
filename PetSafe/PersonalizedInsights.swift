import SwiftUI

struct PersonalizedInsights: View {
    let onboardingData: OnboardingData
    let riskLevel: String // "high" | "medium" | "low"
    let currentCopper: Double
    let copperLimit: Double

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                upgradeBanner

                profileSummaryCard

                copperTodayCard

                insightsSection
            }
            .padding(.vertical)
            .padding(.horizontal)
        }
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

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights for \(onboardingData.dogName.isEmpty ? "your dog" : onboardingData.dogName)")
                .font(.headline)
                .padding(.horizontal, 2)

            personalizedMessageCard

            healthOverviewCard

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


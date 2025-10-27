import SwiftUI

struct PersonalizedInsights: View {
    let onboardingData: OnboardingData
    let riskLevel: String // "high" | "medium" | "low"
    let currentCopper: Double
    let copperLimit: Double

    var body: some View {
        VStack(spacing: 12) {
            personalizedMessageCard
            healthProfileCard
            tipsCard
        }
        .padding()
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

    private var healthProfileCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg").foregroundStyle(.blue)
                Text("\(onboardingData.dogName)'s Health Profile").font(.headline)
            }
            Grid(alignment: .leading) {
                GridRow { Text("Age:").foregroundStyle(.secondary); Text("\(onboardingData.age) years") }
                GridRow { Text("Weight:").foregroundStyle(.secondary); Text("\(onboardingData.weight, specifier: "%.1f") lbs") }
                GridRow { Text("Risk Level:").foregroundStyle(.secondary); Text(riskLevel.capitalized).foregroundStyle(colorForRisk()) }
                GridRow { Text("Daily Limit:").foregroundStyle(.secondary); Text("\(copperLimit, specifier: "%.1f")mg Cu") }
                GridRow { Text("Current Copper:").foregroundStyle(.secondary); Text("\(currentCopper, specifier: "%.2f")mg Cu") }
            }
            if onboardingData.healthConditions.filter({ $0 != "None of the above" }).count > 0 {
                Divider()
                Text("Health Conditions").font(.subheadline.weight(.semibold))
                WrapHStack(items: Array(onboardingData.healthConditions.filter { $0 != "None of the above" })) { item in
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
                WrapHStack(items: Array(onboardingData.dietaryRestrictions.filter { $0 != "No specific restrictions" }.prefix(3))) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
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

struct WrapHStack<Content: View, T: Hashable>: View {
    let items: [T]
    let content: (T) -> Content

    init(items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .padding(4)
                        .alignmentGuide(.leading) { d in
                            if (abs(width) + d.width) > geometry.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            width += d.width
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            return result
                        }
                }
            }
        }
        .frame(minHeight: 24)
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

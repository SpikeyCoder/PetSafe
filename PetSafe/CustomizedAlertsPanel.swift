import SwiftUI


struct CustomizedAlertsPanel: View {
    let currentCopper: Double
    let copperLimit: Double
    let riskLevel: String // "high" | "medium" | "low"
    let recentHighCopperFoods: [String]
    let dismissedAlerts: [String]
    let onboardingData: OnboardingData
    let onDismissAlert: (String) -> Void

    var percentage: Double { (currentCopper / max(copperLimit, 0.001)) * 100.0 }

    struct AlertItem: Identifiable, Equatable {
        let id: String
        let type: String // danger | warning | success | info
        let title: String
        let description: String
        let icon: String
        let actionable: Bool
        let priority: String // critical | high | medium | low
    }

    var alerts: [AlertItem] {
        var items: [AlertItem] = []
        if percentage > 85, riskLevel == "high", !dismissedAlerts.contains("critical-copper") {
            items.append(AlertItem(id: "critical-copper", type: "danger", title: "Critical Alert for \(onboardingData.dogName)", description: "With \(onboardingData.breed) breed risk and \(Int(percentage))% of copper limit reached, immediate dietary adjustment is needed.", icon: "exclamationmark.triangle.fill", actionable: true, priority: "critical"))
        }
        if percentage > 70, onboardingData.healthConditions.contains("Liver Disease"), !dismissedAlerts.contains("liver-alert") {
            items.append(AlertItem(id: "liver-alert", type: "danger", title: "Liver Health Alert", description: "Dogs with liver disease should stay well below copper limits. Consider consulting your vet about today's intake.", icon: "heart.fill", actionable: true, priority: "high"))
        }
        if onboardingData.healthConditions.contains("Copper Storage Disease"), percentage > 60, !dismissedAlerts.contains("csd-alert") {
            items.append(AlertItem(id: "csd-alert", type: "warning", title: "CSD Management Alert", description: "\(onboardingData.dogName) has reached \(Int(percentage))% of the daily limit. Extra caution needed with confirmed Copper Storage Disease.", icon: "shield.fill", actionable: true, priority: "high"))
        }
        if onboardingData.age > 8, percentage > 75, !dismissedAlerts.contains("senior-alert") {
            items.append(AlertItem(id: "senior-alert", type: "warning", title: "Senior Dog Consideration", description: "Senior dogs may process copper differently. At \(onboardingData.age) years old, \(onboardingData.dogName) may benefit from lower copper intake.", icon: "clock.fill", actionable: true, priority: "medium"))
        }
        if onboardingData.dietaryRestrictions.contains("Raw food diet"), !recentHighCopperFoods.isEmpty, !dismissedAlerts.contains("raw-diet-alert") {
            items.append(AlertItem(id: "raw-diet-alert", type: "info", title: "Raw Diet Monitoring", description: "Raw diets can have variable copper content. Recent high-copper foods: \(recentHighCopperFoods.joined(separator: ", ")).", icon: "info.circle.fill", actionable: true, priority: "medium"))
        }
        if onboardingData.vetRecommendations.contains("Monitor copper intake"), percentage > 80, !dismissedAlerts.contains("vet-rec-alert") {
            items.append(AlertItem(id: "vet-rec-alert", type: "warning", title: "Vet Recommendation Alert", description: "Your vet recommended monitoring copper intake. Consider documenting today's levels for your next appointment.", icon: "person.fill", actionable: true, priority: "medium"))
        }
        if percentage < 50, riskLevel == "high", items.isEmpty {
            items.append(AlertItem(id: "breed-success", type: "success", title: "Excellent \(onboardingData.breed) Care!", description: "Great job managing \(onboardingData.dogName)'s copper intake despite breed predisposition. Keep up the careful monitoring!", icon: "checkmark.circle.fill", actionable: false, priority: "low"))
        }
        if onboardingData.primaryConcerns.contains("Weight management"), !dismissedAlerts.contains("weight-alert") {
            items.append(AlertItem(id: "weight-alert", type: "info", title: "Weight Management Tip", description: "At \(Int(onboardingData.weight)) lbs, \(onboardingData.dogName)'s copper limit is \(copperLimit)mg. Portion control helps both weight and copper management.", icon: "chart.line.uptrend.xyaxis", actionable: true, priority: "low"))
        }
        let order = ["critical": 0, "high": 1, "medium": 2, "low": 3]
        return items.sorted { (order[$0.priority] ?? 3) < (order[$1.priority] ?? 3) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Alerts & Insights").font(.headline)
                Spacer()
                Text("\(alerts.count) active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            }

            if alerts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").font(.largeTitle).foregroundStyle(.green)
                    Text("All Clear!").font(.headline)
                    Text("\(onboardingData.dogName) is doing great today. No alerts to show.").font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(alerts) { alert in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: alert.icon).foregroundStyle(iconColor(for: alert.type))
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(alert.title).font(.subheadline.weight(.semibold))
                                    if alert.priority == "critical" {
                                        Text("Critical")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                    if alert.priority == "high" {
                                        Text("High")
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.4)))
                                    }
                                }
                                Text(alert.description).font(.caption)
                            }
                            Spacer()
                            if alert.actionable {
                                Button {
                                    onDismissAlert(alert.id)
                                } label: {
                                    Image(systemName: "xmark").font(.caption)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(10)
                        .background(bgColor(for: alert.type))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor(for: alert.type)))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Divider().padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(onboardingData.dogName)'s Weekly Progress").font(.subheadline.weight(.semibold))
                    HStack {
                        Text("Avg Daily:").foregroundStyle(.secondary)
                        Text("\((currentCopper * 0.8), specifier: "%.1f")mg Cu")
                    }
                    HStack {
                        Text("Compliance:").foregroundStyle(.secondary)
                        Text("85% ").foregroundStyle(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("💡 Tips for \(onboardingData.dogName)").font(.subheadline.weight(.semibold))
                    Group {
                        if onboardingData.healthConditions.contains("Copper Storage Disease") {
                            tip("Work with your vet for regular liver function monitoring")
                            tip("Consider copper-binding medications if recommended")
                            tip("Document symptoms and dietary patterns")
                        } else if onboardingData.dietaryRestrictions.contains("Limited ingredient diet") {
                            tip("Limited ingredient diets naturally reduce copper exposure")
                            tip("Stick to known safe protein sources")
                            tip("Read labels carefully for hidden copper sources")
                        } else {
                            tip("Organ meats (liver, kidney) are very high in copper")
                            tip("Shellfish and nuts should be avoided")
                            tip("Regular monitoring helps establish patterns")
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.15)))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func iconColor(for type: String) -> Color {
        switch type {
        case "danger": return .red
        case "warning": return .orange
        case "success": return .green
        default: return .blue
        }
    }
    private func bgColor(for type: String) -> Color { iconColor(for: type).opacity(0.08) }
    private func borderColor(for type: String) -> Color { iconColor(for: type).opacity(0.2) }

    @ViewBuilder private func tip(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text("•")
            Text(text).font(.caption)
        }
    }
}

#Preview {
    CustomizedAlertsPanel(
        currentCopper: 2.0,
        copperLimit: 5.0,
        riskLevel: "high",
        recentHighCopperFoods: ["Liver Treats", "Grain-Free Salmon"],
        dismissedAlerts: [],
        onboardingData: OnboardingData(
            dogName: "Max",
            breed: "Labrador Retriever",
            age: 7,
            weight: 65,
            healthConditions: ["Copper Storage Disease"],
            dietaryRestrictions: ["Raw food diet"],
            primaryConcerns: ["Weight management"],
            vetRecommendations: ["Monitor copper intake"]
        ),
        onDismissAlert: { _ in }
    )
}

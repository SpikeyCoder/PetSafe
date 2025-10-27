import SwiftUI

struct AlertsPanel: View {
    let currentCopper: Double
    let copperLimit: Double
    let riskLevel: String // "high" | "medium" | "low"
    let recentHighCopperFoods: [String]

    var percentage: Double { (currentCopper / max(copperLimit, 0.001)) * 100.0 }

    var alertMessage: String? {
        if percentage > 85 {
            return "High Copper Intake: \(currentCopper, default: "%.1f")mg (\(Int(percentage))% of limit). Consider reducing copper-rich foods."
        } else if percentage > 70 {
            return "Approaching Copper Limit: \(Int(percentage))%. Monitor remaining meals."
        } else if riskLevel == "high" {
            return "High-Risk Breed: Extra monitoring recommended for copper storage disease."
        } else if !recentHighCopperFoods.isEmpty {
            return "Recent High-Copper Foods: \(recentHighCopperFoods.joined(separator: ", "))"
        } else if percentage < 50 {
            return "Copper intake well within safe limits. Great job!"
        }
        return nil
    }

    var alertIcon: String? {
        if percentage > 85 {
            return "exclamationmark.triangle.fill"
        } else if percentage > 70 {
            return "info.circle.fill"
        } else if riskLevel == "high" {
            return "heart.fill"
        } else if !recentHighCopperFoods.isEmpty {
            return "chart.line.uptrend.xyaxis"
        } else if percentage < 50 {
            return "checkmark.circle.fill"
        }
        return nil
    }

    var alertColor: Color {
        if percentage > 85 {
            return .red
        } else if percentage > 70 {
            return .orange
        } else if riskLevel == "high" {
            return .blue
        } else if !recentHighCopperFoods.isEmpty {
            return .blue
        } else if percentage < 50 {
            return .green
        }
        return .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alerts & Recommendations")
                .font(.headline)

            if let message = alertMessage, let icon = alertIcon {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: icon)
                        .foregroundColor(alertColor)
                        .font(.title2)
                    Text(message)
                        .font(.subheadline)
                }
                .padding()
                .background(alertColor.opacity(0.1))
                .cornerRadius(10)
            } else {
                Text("No alerts at this time.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        AlertsPanel(currentCopper: 4.5, copperLimit: 5.0, riskLevel: "low", recentHighCopperFoods: [])
        AlertsPanel(currentCopper: 3.8, copperLimit: 5.0, riskLevel: "medium", recentHighCopperFoods: ["Liver Treats"])
        AlertsPanel(currentCopper: 2.0, copperLimit: 5.0, riskLevel: "high", recentHighCopperFoods: [])
        AlertsPanel(currentCopper: 1.5, copperLimit: 5.0, riskLevel: "low", recentHighCopperFoods: [])
    }
    .padding()
}

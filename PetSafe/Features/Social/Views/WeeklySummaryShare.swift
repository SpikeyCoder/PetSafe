import SwiftUI
import UIKit

// MARK: - Weekly Summary Share View
/// Generates beautiful shareable graphics for weekly copper tracking
struct WeeklySummaryShareView: View {
    let weekData: WeeklyData
    let dogName: String
    @Environment(\.dismiss) private var dismiss

    @State private var generatedImage: UIImage?
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Preview of shareable card
                    shareableCard
                        .padding()

                    // Share button
                    shareButton

                    // Stats breakdown
                    statsBreakdown
                }
            }
            .navigationTitle("Weekly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Shareable Card
    private var shareableCard: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.Spacing.md) {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.Colors.orange600)

                    Text("\(dogName)'s Week")
                        .font(Theme.Typography.title)

                    Spacer()
                }

                Text(weekData.dateRange)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Theme.Colors.orange50)

            Divider()

            // Main metrics
            VStack(spacing: Theme.Spacing.lg) {
                // Safety score
                VStack(spacing: Theme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: weekData.safetyScore / 100)
                            .stroke(
                                weekData.safetyColor,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text("\(Int(weekData.safetyScore))%")
                                .font(Theme.Typography.customTitle(32))
                                .fontWeight(.bold)
                            Text("Safe")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(weekData.safetyMessage)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Divider()

                // Quick stats
                HStack(spacing: Theme.Spacing.xl) {
                    quickStat(
                        icon: "flame.fill",
                        value: "\(weekData.streakDays)",
                        label: "Day Streak",
                        color: Theme.Colors.orange600
                    )

                    quickStat(
                        icon: "fork.knife",
                        value: "\(weekData.totalEntries)",
                        label: "Foods Logged",
                        color: Theme.Colors.blue600
                    )

                    quickStat(
                        icon: "drop.fill",
                        value: String(format: "%.1f", weekData.avgDailyCopper),
                        label: "Avg mg/day",
                        color: Theme.Colors.safeGreen
                    )
                }

                // Chart (simplified bar chart)
                weeklyChart

                // Achievement highlights
                if !weekData.achievementsUnlocked.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("🏆 Achievements This Week")
                            .font(Theme.Typography.headline)

                        ForEach(weekData.achievementsUnlocked, id: \.self) { achievement in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color.yellow)
                                Text(achievement)
                                    .font(Theme.Typography.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
                }
            }
            .padding()

            Divider()

            // Footer
            HStack {
                Spacer()
                Text("Tracked with PetSafe")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "pawprint.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.orange600)
                Spacer()
            }
            .padding()
            .background(Theme.Colors.orange50)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.xl))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }

    private func quickStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(Theme.Typography.headline)
                .fontWeight(.bold)
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Chart
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Daily Copper Intake")
                .font(Theme.Typography.subheadline.weight(.semibold))

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(weekData.dailyValues.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(
                                weekData.dailyValues[index] > weekData.dailyLimit ?
                                Theme.Colors.dangerRed : Theme.Colors.safeGreen
                            )
                            .frame(
                                width: 30,
                                height: max(
                                    20,
                                    CGFloat(weekData.dailyValues[index] / weekData.dailyLimit) * 100
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text(weekData.dayLabels[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }

    // MARK: - Stats Breakdown
    private var statsBreakdown: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("This Week's Details")
                .font(Theme.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Theme.Spacing.sm) {
                statRow(label: "Perfect Days", value: "\(weekData.perfectDays) / 7")
                statRow(label: "Foods Scanned", value: "\(weekData.foodsScanned)")
                statRow(label: "Total Copper", value: String(format: "%.1f mg", weekData.totalCopper))
                statRow(label: "Safest Food", value: weekData.safestFood)
                statRow(label: "Highest Food", value: weekData.highestFood)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
        .padding()
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.subheadline.weight(.semibold))
        }
    }

    // MARK: - Share Button
    private var shareButton: some View {
        Button {
            shareImage()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Weekly Summary")
            }
            .font(Theme.Typography.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.orange600)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
        .padding(.horizontal)
        .disabled(isExporting)
    }

    // MARK: - Share Logic
    private func shareImage() {
        isExporting = true

        // Generate image from view
        let renderer = ImageRenderer(content: shareableCard)
        renderer.scale = 3.0 // Retina quality

        if let image = renderer.uiImage {
            generatedImage = image

            // Present share sheet
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }

        isExporting = false
    }
}

// MARK: - Weekly Data Model
struct WeeklyData {
    let dateRange: String
    let safetyScore: Double // 0-100
    let safetyMessage: String
    let safetyColor: Color
    let streakDays: Int
    let totalEntries: Int
    let avgDailyCopper: Double
    let dailyValues: [Double]
    let dayLabels: [String]
    let dailyLimit: Double
    let achievementsUnlocked: [String]
    let perfectDays: Int
    let foodsScanned: Int
    let totalCopper: Double
    let safestFood: String
    let highestFood: String

    static var preview: WeeklyData {
        WeeklyData(
            dateRange: "Feb 3 - Feb 9, 2026",
            safetyScore: 92,
            safetyMessage: "Excellent! You stayed under limit all week",
            safetyColor: Theme.Colors.safeGreen,
            streakDays: 14,
            totalEntries: 21,
            avgDailyCopper: 3.2,
            dailyValues: [2.5, 3.1, 2.8, 3.5, 4.2, 2.9, 3.4],
            dayLabels: ["M", "T", "W", "T", "F", "S", "S"],
            dailyLimit: 5.0,
            achievementsUnlocked: ["7 Day Streak", "Perfect Week"],
            perfectDays: 7,
            foodsScanned: 8,
            totalCopper: 22.4,
            safestFood: "Chicken & Rice",
            highestFood: "Beef Liver Treat"
        )
    }
}

// MARK: - Previews
#Preview("Weekly Summary Share") {
    WeeklySummaryShareView(
        weekData: .preview,
        dogName: "Max"
    )
}

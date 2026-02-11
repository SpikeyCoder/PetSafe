import SwiftUI

// MARK: - Food Log View
/// Displays daily food entries with copper tracking
struct FoodLogView: View {
    @ObservedObject var viewModel: FoodLogViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Date selector
            dateSelector

            Divider()

            if viewModel.todaysEntries.isEmpty {
                emptyState
            } else {
                // Entries list
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Daily summary
                        dailySummaryCard

                        // Entries
                        VStack(spacing: Theme.Spacing.sm) {
                            ForEach(viewModel.todaysEntries) { entry in
                                FoodEntryRow(entry: entry)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.loadEntries()
        }
    }

    // MARK: - Date Selector
    private var dateSelector: some View {
        HStack {
            Button {
                viewModel.selectPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.selectedDate, style: .date)
                    .font(Theme.Typography.headline)
                if viewModel.isToday {
                    Text("Today")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.orange600)
                }
            }

            Spacer()

            Button {
                viewModel.selectNextDay()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(viewModel.isToday)
        }
        .padding()
    }

    // MARK: - Daily Summary Card
    private var dailySummaryCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Copper progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Copper")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", viewModel.totalCopperToday))
                            .font(Theme.Typography.customTitle(28))
                            .fontWeight(.bold)
                            .foregroundStyle(viewModel.copperStatus.color)
                        Text("mg")
                            .font(Theme.Typography.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.copperStatus.iconName)
                        Text(viewModel.copperStatus.text)
                    }
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.copperStatus.color)
                    .badgeStyle(
                        backgroundColor: viewModel.copperStatus.backgroundColor,
                        foregroundColor: viewModel.copperStatus.color
                    )

                    Text("\(viewModel.remainingCopper, specifier: "%.1f") mg remaining")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))

                    Capsule()
                        .fill(viewModel.copperStatus.color)
                        .frame(width: geometry.size.width * (viewModel.copperPercentage / 100))
                        .animation(.easeInOut, value: viewModel.copperPercentage)
                }
            }
            .frame(height: 8)

            Divider()

            // Stats row
            HStack {
                statItem(
                    icon: "fork.knife",
                    label: "Items",
                    value: "\(viewModel.todaysEntries.count)"
                )

                Spacer()

                statItem(
                    icon: "scalemass",
                    label: "Total",
                    value: "\(viewModel.totalWeightToday, default: "%.0f")g"
                )

                Spacer()

                statItem(
                    icon: "percent",
                    label: "Daily Limit",
                    value: "\(viewModel.copperPercentage, default: "%.0f")%"
                )
            }
        }
        .cardStyle(
            backgroundColor: viewModel.copperStatus.backgroundColor,
            borderColor: viewModel.copperStatus.borderColor
        )
    }

    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(viewModel.copperStatus.color)
            Text(value)
                .font(Theme.Typography.subheadline.weight(.semibold))
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No food logged")
                .font(Theme.Typography.headline)

            Text(viewModel.isToday ? "Start tracking by scanning a barcode or adding food manually" : "No entries for this day")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Food Entry Row
struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.timestamp, style: .time)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, alignment: .leading)

            // Food info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.name)
                        .font(Theme.Typography.subheadline.weight(.semibold))

                    if entry.isLimitedIngredient {
                        Text("LI")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                Text(entry.brand)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.md) {
                    Label(
                        "\(entry.amount, specifier: "%.0f")g",
                        systemImage: "scalemass"
                    )
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                    Label(
                        "\(entry.totalCopperContent, specifier: "%.2f") mg Cu",
                        systemImage: "drop.fill"
                    )
                    .font(Theme.Typography.caption)
                    .foregroundStyle(copperColor(entry.totalCopperContent))
                }
            }

            Spacer()

            // Safety indicator
            Image(systemName: entry.safetyLevel.iconName)
                .foregroundStyle(safetyColor(entry.safetyLevel))
        }
        .padding(Theme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    private func copperColor(_ value: Double) -> Color {
        if value < 0.5 {
            return Theme.Colors.safeGreen
        } else if value < 1.5 {
            return Theme.Colors.warningYellow
        } else {
            return Theme.Colors.dangerRed
        }
    }

    private func safetyColor(_ level: FoodSafetyLevel) -> Color {
        switch level {
        case .safe: return Theme.Colors.safeGreen
        case .caution: return Theme.Colors.warningYellow
        case .danger: return Theme.Colors.dangerRed
        }
    }
}

// MARK: - Previews
#Preview("Food Log - With Entries") {
    NavigationStack {
        FoodLogView(viewModel: .preview)
            .navigationTitle("Food Log")
    }
}

#Preview("Food Entry Row") {
    FoodEntryRow(entry: FoodEntry.sampleEntries[0])
        .padding()
}

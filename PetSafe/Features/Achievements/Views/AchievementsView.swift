import SwiftUI
internal import Combine
import SwiftData

// MARK: - Achievements View
/// Display user achievements, streaks, and progress
struct AchievementsView: View {
    @ObservedObject var progressViewModel: ProgressViewModel

    @State private var selectedCategory: Achievement.AchievementCategory = .all
    @State private var showingConfetti = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header with streak and level
                headerCard

                // Category filter
                categoryPicker

                // Achievements grid
                achievementsGrid
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .confettiCannon(counter: $showingConfetti, num: 50, radius: 300)
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Streak display
            HStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            progressViewModel.progress.currentStreak > 0 ?
                            Theme.Colors.orange600 : .gray
                        )

                    Text("\(progressViewModel.progress.currentStreak)")
                        .font(Theme.Typography.customTitle(28))
                        .fontWeight(.bold)

                    Text("Day Streak")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 60)

                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.yellow)

                    Text("\(progressViewModel.progress.longestStreak)")
                        .font(Theme.Typography.customTitle(28))
                        .fontWeight(.bold)

                    Text("Best Streak")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            // Level and XP
            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Text("Level \(progressViewModel.progress.level)")
                        .font(Theme.Typography.headline)
                    Spacer()
                    Text("\(progressViewModel.progress.experiencePoints) / \(progressViewModel.progress.experienceToNextLevel) XP")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))

                        Capsule()
                            .fill(Theme.Colors.blue600)
                            .frame(width: geometry.size.width * progressViewModel.progress.experienceProgress)
                            .animation(.spring(), value: progressViewModel.progress.experienceProgress)
                    }
                }
                .frame(height: 8)
            }

            // Stats
            HStack {
                statBadge(icon: "barcode.viewfinder", value: "\(progressViewModel.progress.totalScans)", label: "Scans")
                statBadge(icon: "fork.knife", value: "\(progressViewModel.progress.totalEntries)", label: "Entries")
                statBadge(icon: "star.fill", value: "\(progressViewModel.progress.unlockedAchievements.count)", label: "Unlocked")
            }
        }
        .cardStyle()
    }

    private func statBadge(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Colors.blue600)
            Text(value)
                .font(Theme.Typography.subheadline.weight(.semibold))
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Category Picker
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                categoryButton(.all)

                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func categoryButton(_ category: Achievement.AchievementCategory) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedCategory = category
            }
        } label: {
            Text(category.rawValue)
                .font(Theme.Typography.subheadline.weight(.medium))
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    selectedCategory == category ?
                    Theme.Colors.orange600 : Color(.secondarySystemBackground)
                )
                .foregroundStyle(selectedCategory == category ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Achievements Grid
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Theme.Spacing.md),
            GridItem(.flexible(), spacing: Theme.Spacing.md)
        ], spacing: Theme.Spacing.md) {
            ForEach(filteredAchievements) { achievement in
                AchievementCard(
                    achievement: achievement,
                    progress: progressViewModel.progress
                )
            }
        }
    }

    private var filteredAchievements: [Achievement] {
        if selectedCategory == .all {
            return Achievement.all
        }
        return Achievement.all.filter { $0.category == selectedCategory }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    let progress: UserProgress

    private var isUnlocked: Bool {
        progress.hasUnlocked(achievement.id)
    }

    private var currentProgress: Int {
        progress.getProgress(for: achievement.id)
    }

    private var progressPercentage: Double {
        min(Double(currentProgress) / Double(achievement.requiredProgress), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Icon
            HStack {
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(isUnlocked ? achievement.color : .gray)

                Spacer()

                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.Colors.safeGreen)
                }
            }

            // Title
            Text(achievement.title)
                .font(Theme.Typography.subheadline.weight(.semibold))
                .lineLimit(2)
                .foregroundStyle(isUnlocked ? .primary : .secondary)

            // Description
            Text(achievement.description)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Progress bar (if not unlocked)
            if !isUnlocked {
                VStack(spacing: 2) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))

                            Capsule()
                                .fill(achievement.color)
                                .frame(width: geometry.size.width * progressPercentage)
                        }
                    }
                    .frame(height: 4)

                    HStack {
                        Text("\(currentProgress) / \(achievement.requiredProgress)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            } else {
                // XP reward
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.yellow)
                    Text("+\(achievement.experienceReward) XP")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            isUnlocked ?
            achievement.color.opacity(0.1) :
            Color(.secondarySystemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(
                    isUnlocked ? achievement.color.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Category Extension
extension Achievement.AchievementCategory {
    static let all = Achievement.AchievementCategory.scanning // Using as placeholder for "All"
}

// MARK: - Confetti Modifier
struct ConfettiCannon: ViewModifier {
    @Binding var counter: Bool
    var num: Int
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<num, id: \.self) { _ in
                            ConfettiPiece(containerSize: geometry.size, trigger: counter)
                        }
                    }
                    .opacity(counter ? 1 : 0)
                    .animation(.easeOut(duration: 3), value: counter)
                }
                .allowsHitTesting(false)
            )
    }
}

struct ConfettiPiece: View {
    let containerSize: CGSize
    let trigger: Bool
    
    @State private var location: CGPoint
    @State private var opacity = 1.0

    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    init(containerSize: CGSize, trigger: Bool) {
        self.containerSize = containerSize
        self.trigger = trigger
        _location = State(initialValue: CGPoint(x: containerSize.width / 2, y: -20))
    }

    var body: some View {
        Circle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: 10, height: 10)
            .position(location)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 3)) {
                    location = CGPoint(
                        x: CGFloat.random(in: 0...containerSize.width),
                        y: containerSize.height + 20
                    )
                    opacity = 0
                }
            }
    }
}

extension View {
    func confettiCannon(counter: Binding<Bool>, num: Int, radius: CGFloat) -> some View {
        self.modifier(ConfettiCannon(counter: counter, num: num, radius: radius))
    }
}

// MARK: - Progress ViewModel
@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var progress: UserProgress

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Load or create user progress
        let descriptor = FetchDescriptor<UserProgress>()
        if let existingProgress = try? modelContext.fetch(descriptor).first {
            self.progress = existingProgress
        } else {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            self.progress = newProgress
        }
    }

    // MARK: - Achievement Checking
    func checkAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in Achievement.all {
            guard !progress.hasUnlocked(achievement.id) else { continue }

            let meetsRequirement: Bool

            switch achievement.id {
            case "first_scan", "scan_10", "scan_50", "scan_100":
                meetsRequirement = progress.uniqueProductsScanned.count >= achievement.requiredProgress
            case "first_entry", "log_100", "log_500":
                meetsRequirement = progress.totalEntries >= achievement.requiredProgress
            case "streak_3", "streak_7", "streak_30", "streak_100", "streak_365":
                meetsRequirement = progress.currentStreak >= achievement.requiredProgress
            case "perfect_day", "perfect_week", "perfect_30":
                meetsRequirement = progress.perfectDays >= achievement.requiredProgress
            case "first_share", "share_10":
                meetsRequirement = progress.totalSharesPerformed >= achievement.requiredProgress
            case "level_5", "level_10":
                meetsRequirement = progress.level >= achievement.requiredProgress
            default:
                meetsRequirement = false
            }

            if meetsRequirement {
                if progress.unlockAchievement(achievement.id) {
                    _ = progress.addExperience(achievement.experienceReward)
                    newlyUnlocked.append(achievement)
                }
            }
        }

        if !newlyUnlocked.isEmpty {
            saveContext()
        }

        return newlyUnlocked
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving progress: \(error)")
        }
    }
}

// MARK: - Previews
#Preview("Achievements View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProgress.self, configurations: config)
    let context = container.mainContext

    let progress = UserProgress.preview
    context.insert(progress)

    let viewModel = ProgressViewModel(modelContext: context)

    return NavigationStack {
        AchievementsView(progressViewModel: viewModel)
    }
    .modelContainer(container)
}

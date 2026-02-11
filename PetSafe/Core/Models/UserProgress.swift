import Foundation
import SwiftData
import SwiftUI

// MARK: - User Progress Model
/// Tracks streaks, achievements, and gamification stats
@Model
final class UserProgress {
    // MARK: - Properties
    var id: UUID
    var userId: String?

    // Streak tracking
    var currentStreak: Int
    var longestStreak: Int
    var lastLoggedDate: Date?
    var streakFreezes: Int // Number of "freeze" days available

    // Achievement tracking
    var unlockedAchievements: [String] // Achievement IDs
    var achievementProgress: [String: Int] // Achievement ID : Progress

    // Statistics
    var totalScans: Int
    var totalEntries: Int
    var uniqueProductsScanned: Set<String> // Barcodes
    var perfectDays: Int // Days staying under copper limit
    var totalCopperTracked: Double

    // Gamification
    var level: Int
    var experiencePoints: Int
    var totalSharesPerformed: Int

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties
    var experienceToNextLevel: Int {
        level * 100 // Level 1 needs 100 XP, Level 2 needs 200 XP, etc.
    }

    var experienceProgress: Double {
        Double(experiencePoints) / Double(experienceToNextLevel)
    }

    var canUseStreakFreeze: Bool {
        streakFreezes > 0
    }

    // MARK: - Initialization
    init(
        userId: String? = nil,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastLoggedDate: Date? = nil,
        streakFreezes: Int = 0,
        unlockedAchievements: [String] = [],
        achievementProgress: [String: Int] = [:],
        totalScans: Int = 0,
        totalEntries: Int = 0,
        uniqueProductsScanned: Set<String> = [],
        perfectDays: Int = 0,
        totalCopperTracked: Double = 0,
        level: Int = 1,
        experiencePoints: Int = 0,
        totalSharesPerformed: Int = 0
    ) {
        self.id = UUID()
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastLoggedDate = lastLoggedDate
        self.streakFreezes = streakFreezes
        self.unlockedAchievements = unlockedAchievements
        self.achievementProgress = achievementProgress
        self.totalScans = totalScans
        self.totalEntries = totalEntries
        self.uniqueProductsScanned = uniqueProductsScanned
        self.perfectDays = perfectDays
        self.totalCopperTracked = totalCopperTracked
        self.level = level
        self.experiencePoints = experiencePoints
        self.totalSharesPerformed = totalSharesPerformed
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Streak Management
    func updateStreak(for date: Date = Date()) {
        let calendar = Calendar.current

        guard let lastDate = lastLoggedDate else {
            // First time logging
            currentStreak = 1
            longestStreak = 1
            lastLoggedDate = date
            updatedAt = Date()
            return
        }

        // Check if already logged today
        if calendar.isDate(lastDate, inSameDayAs: date) {
            return
        }

        // Check if logged yesterday (streak continues)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: date),
           calendar.isDate(lastDate, inSameDayAs: yesterday) {
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            // Streak broken
            currentStreak = 1
        }

        lastLoggedDate = date
        updatedAt = Date()
    }

    func useStreakFreeze() {
        guard canUseStreakFreeze else { return }
        streakFreezes -= 1

        // Extend streak by one day
        if let lastDate = lastLoggedDate {
            lastLoggedDate = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)
        }

        updatedAt = Date()
    }

    func earnStreakFreeze() {
        streakFreezes += 1
        updatedAt = Date()
    }

    // MARK: - Achievement Management
    func unlockAchievement(_ achievementId: String) -> Bool {
        guard !unlockedAchievements.contains(achievementId) else {
            return false
        }

        unlockedAchievements.append(achievementId)
        updatedAt = Date()
        return true
    }

    func hasUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievements.contains(achievementId)
    }

    func incrementProgress(for achievementId: String, by amount: Int = 1) {
        let current = achievementProgress[achievementId] ?? 0
        achievementProgress[achievementId] = current + amount
        updatedAt = Date()
    }

    func getProgress(for achievementId: String) -> Int {
        achievementProgress[achievementId] ?? 0
    }

    // MARK: - Statistics Updates
    func recordScan(barcode: String) {
        totalScans += 1
        uniqueProductsScanned.insert(barcode)
        updatedAt = Date()
    }

    func recordEntry(copperAmount: Double) {
        totalEntries += 1
        totalCopperTracked += copperAmount
        updatedAt = Date()
    }

    func recordPerfectDay() {
        perfectDays += 1
        updatedAt = Date()
    }

    func recordShare() {
        totalSharesPerformed += 1
        updatedAt = Date()
    }

    // MARK: - Level & XP Management
    func addExperience(_ amount: Int) -> Bool {
        experiencePoints += amount

        // Check for level up
        while experiencePoints >= experienceToNextLevel {
            experiencePoints -= experienceToNextLevel
            level += 1
            updatedAt = Date()
            return true // Level up occurred
        }

        updatedAt = Date()
        return false // No level up
    }
}

// MARK: - Achievement Definition
struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requiredProgress: Int
    let experienceReward: Int
    let category: AchievementCategory

    enum AchievementCategory: String, CaseIterable {
        case scanning = "Scanning"
        case logging = "Logging"
        case streak = "Streaks"
        case safety = "Safety"
        case social = "Social"
        case expert = "Expert"
    }

    // MARK: - All Achievements
    static let all: [Achievement] = [
        // Scanning achievements
        Achievement(
            id: "first_scan",
            title: "First Scan",
            description: "Scan your first product",
            icon: "barcode.viewfinder",
            color: Theme.Colors.orange600,
            requiredProgress: 1,
            experienceReward: 50,
            category: .scanning
        ),
        Achievement(
            id: "scan_10",
            title: "Scanner Novice",
            description: "Scan 10 different products",
            icon: "camera.fill",
            color: Theme.Colors.blue600,
            requiredProgress: 10,
            experienceReward: 100,
            category: .scanning
        ),
        Achievement(
            id: "scan_50",
            title: "Product Detective",
            description: "Scan 50 different products",
            icon: "magnifyingglass",
            color: Theme.Colors.blue600,
            requiredProgress: 50,
            experienceReward: 250,
            category: .scanning
        ),
        Achievement(
            id: "scan_100",
            title: "Barcode Master",
            description: "Scan 100 different products",
            icon: "star.fill",
            color: Color.yellow,
            requiredProgress: 100,
            experienceReward: 500,
            category: .scanning
        ),

        // Logging achievements
        Achievement(
            id: "first_entry",
            title: "Getting Started",
            description: "Log your first food entry",
            icon: "fork.knife",
            color: Theme.Colors.orange600,
            requiredProgress: 1,
            experienceReward: 25,
            category: .logging
        ),
        Achievement(
            id: "log_100",
            title: "Data Enthusiast",
            description: "Log 100 food entries",
            icon: "chart.bar.fill",
            color: Theme.Colors.blue600,
            requiredProgress: 100,
            experienceReward: 200,
            category: .logging
        ),
        Achievement(
            id: "log_500",
            title: "Dedicated Tracker",
            description: "Log 500 food entries",
            icon: "chart.line.uptrend.xyaxis",
            color: Theme.Colors.blue600,
            requiredProgress: 500,
            experienceReward: 750,
            category: .logging
        ),

        // Streak achievements
        Achievement(
            id: "streak_3",
            title: "Committed",
            description: "3 day logging streak",
            icon: "flame",
            color: Theme.Colors.orange600,
            requiredProgress: 3,
            experienceReward: 75,
            category: .streak
        ),
        Achievement(
            id: "streak_7",
            title: "One Week Wonder",
            description: "7 day logging streak",
            icon: "flame.fill",
            color: Theme.Colors.orange600,
            requiredProgress: 7,
            experienceReward: 150,
            category: .streak
        ),
        Achievement(
            id: "streak_30",
            title: "Monthly Champion",
            description: "30 day logging streak",
            icon: "medal.fill",
            color: Color.yellow,
            requiredProgress: 30,
            experienceReward: 500,
            category: .streak
        ),
        Achievement(
            id: "streak_100",
            title: "Centurion",
            description: "100 day logging streak",
            icon: "crown.fill",
            color: Color.yellow,
            requiredProgress: 100,
            experienceReward: 1500,
            category: .streak
        ),
        Achievement(
            id: "streak_365",
            title: "Year of Safety",
            description: "365 day logging streak",
            icon: "trophy.fill",
            color: Color.yellow,
            requiredProgress: 365,
            experienceReward: 5000,
            category: .streak
        ),

        // Safety achievements
        Achievement(
            id: "perfect_day",
            title: "Perfect Day",
            description: "Stay under copper limit for a day",
            icon: "checkmark.circle.fill",
            color: Theme.Colors.safeGreen,
            requiredProgress: 1,
            experienceReward: 50,
            category: .safety
        ),
        Achievement(
            id: "perfect_week",
            title: "Safety First",
            description: "Stay under limit for 7 consecutive days",
            icon: "checkmark.seal.fill",
            color: Theme.Colors.safeGreen,
            requiredProgress: 7,
            experienceReward: 200,
            category: .safety
        ),
        Achievement(
            id: "perfect_30",
            title: "Safety Guardian",
            description: "Stay under limit for 30 consecutive days",
            icon: "shield.fill",
            color: Theme.Colors.safeGreen,
            requiredProgress: 30,
            experienceReward: 750,
            category: .safety
        ),

        // Social achievements
        Achievement(
            id: "first_share",
            title: "Spread the Word",
            description: "Share your first weekly report",
            icon: "square.and.arrow.up.fill",
            color: Theme.Colors.blue600,
            requiredProgress: 1,
            experienceReward: 75,
            category: .social
        ),
        Achievement(
            id: "share_10",
            title: "Advocate",
            description: "Share 10 times",
            icon: "megaphone.fill",
            color: Theme.Colors.blue600,
            requiredProgress: 10,
            experienceReward: 300,
            category: .social
        ),

        // Expert achievements
        Achievement(
            id: "level_5",
            title: "Copper Expert",
            description: "Reach level 5",
            icon: "graduationcap.fill",
            color: Theme.Colors.blue600,
            requiredProgress: 5,
            experienceReward: 0,
            category: .expert
        ),
        Achievement(
            id: "level_10",
            title: "Master Tracker",
            description: "Reach level 10",
            icon: "star.circle.fill",
            color: Color.yellow,
            requiredProgress: 10,
            experienceReward: 0,
            category: .expert
        ),
    ]

    static func forId(_ id: String) -> Achievement? {
        all.first { $0.id == id }
    }
}

// MARK: - Preview Helper
extension UserProgress {
    static var preview: UserProgress {
        let progress = UserProgress(
            currentStreak: 14,
            longestStreak: 42,
            lastLoggedDate: Date(),
            streakFreezes: 2,
            unlockedAchievements: ["first_scan", "first_entry", "streak_7"],
            totalScans: 45,
            totalEntries: 156,
            perfectDays: 12,
            level: 3,
            experiencePoints: 150
        )

        var products = Set<String>()
        for i in 1...45 {
            products.insert("product_\(i)")
        }
        progress.uniqueProductsScanned = products

        return progress
    }
}

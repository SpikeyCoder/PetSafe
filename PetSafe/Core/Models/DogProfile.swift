import Foundation
import SwiftData

/// Represents the dog's profile and health information
/// Stores data collected during onboarding and updated by user
@Model
final class DogProfile {
    var id: UUID
    var name: String
    var breed: String
    var age: Int
    var weight: Double // pounds
    var healthConditions: [String]
    var dietaryRestrictions: [String]
    var primaryConcerns: [String]
    var vetRecommendations: [String]
    var dailyCopperLimit: Double // mg
    var profileImageData: Data?
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade)
    var foodEntries: [FoodEntry] = []

    // Computed properties
    var riskLevel: RiskLevel {
        if healthConditions.contains("Copper Storage Disease") {
            return .high
        } else if healthConditions.contains("Liver Disease") || healthConditions.contains("Chronic Hepatitis") {
            return .medium
        } else {
            return .low
        }
    }

    var hasCopperStorageDisease: Bool {
        healthConditions.contains("Copper Storage Disease")
    }

    var todaysCopperIntake: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return foodEntries
            .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.totalCopperContent }
    }

    var copperPercentage: Double {
        guard dailyCopperLimit > 0 else { return 0 }
        return min((todaysCopperIntake / dailyCopperLimit) * 100, 100)
    }

    var copperStatus: CopperStatus {
        if copperPercentage < 70 {
            return .safe
        } else if copperPercentage < 90 {
            return .caution
        } else {
            return .danger
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        breed: String,
        age: Int,
        weight: Double,
        healthConditions: [String] = [],
        dietaryRestrictions: [String] = [],
        primaryConcerns: [String] = [],
        vetRecommendations: [String] = [],
        dailyCopperLimit: Double = 5.0,
        profileImageData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.weight = weight
        self.healthConditions = healthConditions
        self.dietaryRestrictions = dietaryRestrictions
        self.primaryConcerns = primaryConcerns
        self.vetRecommendations = vetRecommendations
        self.dailyCopperLimit = dailyCopperLimit
        self.profileImageData = profileImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func updateProfile(
        name: String? = nil,
        breed: String? = nil,
        age: Int? = nil,
        weight: Double? = nil,
        healthConditions: [String]? = nil,
        dietaryRestrictions: [String]? = nil,
        primaryConcerns: [String]? = nil,
        vetRecommendations: [String]? = nil,
        dailyCopperLimit: Double? = nil
    ) {
        if let name = name { self.name = name }
        if let breed = breed { self.breed = breed }
        if let age = age { self.age = age }
        if let weight = weight { self.weight = weight }
        if let healthConditions = healthConditions { self.healthConditions = healthConditions }
        if let dietaryRestrictions = dietaryRestrictions { self.dietaryRestrictions = dietaryRestrictions }
        if let primaryConcerns = primaryConcerns { self.primaryConcerns = primaryConcerns }
        if let vetRecommendations = vetRecommendations { self.vetRecommendations = vetRecommendations }
        if let dailyCopperLimit = dailyCopperLimit { self.dailyCopperLimit = dailyCopperLimit }
        self.updatedAt = Date()
    }
}

// MARK: - Risk Level
enum RiskLevel: String, Codable {
    case low
    case medium
    case high

    var displayText: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.shield.fill"
        case .high: return "xmark.shield.fill"
        }
    }
}

// MARK: - Copper Status
enum CopperStatus: String {
    case safe
    case caution
    case danger

    var displayText: String {
        rawValue.capitalized
    }
}

// MARK: - Conversion Helper
extension DogProfile {
    /// Convert from OnboardingData to DogProfile
    static func from(onboardingData: OnboardingData) -> DogProfile {
        // Calculate daily copper limit based on weight and health conditions
        let baseCopperLimit: Double = 5.0 // mg per day baseline
        let weightFactor = onboardingData.weight / 50.0 // adjust for dog size
        let healthAdjustment: Double = onboardingData.healthConditions.contains("Copper Storage Disease") ? 0.6 : 1.0

        let calculatedLimit = baseCopperLimit * weightFactor * healthAdjustment

        return DogProfile(
            name: onboardingData.dogName,
            breed: onboardingData.breed,
            age: onboardingData.age,
            weight: onboardingData.weight,
            healthConditions: onboardingData.healthConditions,
            dietaryRestrictions: onboardingData.dietaryRestrictions,
            primaryConcerns: onboardingData.primaryConcerns,
            vetRecommendations: onboardingData.vetRecommendations,
            dailyCopperLimit: calculatedLimit
        )
    }

    /// Convert to OnboardingData for backward compatibility
    func toOnboardingData() -> OnboardingData {
        OnboardingData(
            dogName: name,
            breed: breed,
            age: age,
            weight: weight,
            healthConditions: healthConditions,
            dietaryRestrictions: dietaryRestrictions,
            primaryConcerns: primaryConcerns,
            vetRecommendations: vetRecommendations
        )
    }
}

// MARK: - Sample Data for Previews
extension DogProfile {
    static var sampleProfile: DogProfile {
        DogProfile(
            name: "Max",
            breed: "Labrador Retriever",
            age: 7,
            weight: 65,
            healthConditions: ["Copper Storage Disease"],
            dietaryRestrictions: ["Low-copper diet"],
            primaryConcerns: ["Copper toxicity prevention"],
            vetRecommendations: ["Monitor copper intake", "Regular liver function tests"],
            dailyCopperLimit: 3.5
        )
    }
}

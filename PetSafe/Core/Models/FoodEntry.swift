import Foundation
import SwiftData
import SwiftUI

/// Represents a single food entry logged by the user
/// Tracks food consumed by the dog with copper content analysis
@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var brand: String
    var amount: Double // grams
    var copperContentPer100g: Double // mg per 100g
    var timestamp: Date
    var isLimitedIngredient: Bool
    var barcode: String?
    var imageData: Data?
    var notes: String?

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \DogProfile.foodEntries)
    var dogProfile: DogProfile?

    // Computed properties
    var totalCopperContent: Double {
        (copperContentPer100g * amount) / 100.0
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var safetyLevel: FoodSafetyLevel {
        if totalCopperContent < 0.5 {
            return .safe
        } else if totalCopperContent < 1.5 {
            return .caution
        } else {
            return .danger
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        amount: Double,
        copperContentPer100g: Double,
        timestamp: Date = Date(),
        isLimitedIngredient: Bool = false,
        barcode: String? = nil,
        imageData: Data? = nil,
        notes: String? = nil,
        dogProfile: DogProfile? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.amount = amount
        self.copperContentPer100g = copperContentPer100g
        self.timestamp = timestamp
        self.isLimitedIngredient = isLimitedIngredient
        self.barcode = barcode
        self.imageData = imageData
        self.notes = notes
        self.dogProfile = dogProfile
    }
}

// MARK: - Food Safety Level
enum FoodSafetyLevel: String, Codable {
    case safe
    case caution
    case danger

    var displayText: String {
        switch self {
        case .safe: return "Safe"
        case .caution: return "Caution"
        case .danger: return "Danger"
        }
    }

    var iconName: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .safe: return Theme.Colors.green50
        case .caution: return Theme.Colors.yellow50
        case .danger: return Theme.Colors.red50
        }
    }
    
    var borderColor: Color {
        switch self {
        case .safe: return Theme.Colors.safeGreen
        case .caution: return Theme.Colors.warningYellow
        case .danger: return Theme.Colors.dangerRed
        }
    }
}

// MARK: - Sample Data for Previews
extension FoodEntry {
    static var sampleEntries: [FoodEntry] {
        [
            FoodEntry(
                name: "Senior Dog Food",
                brand: "Hill's Science Diet",
                amount: 150,
                copperContentPer100g: 1.2,
                timestamp: Date().addingTimeInterval(-3600),
                isLimitedIngredient: false
            ),
            FoodEntry(
                name: "Limited Ingredient Duck",
                brand: "Blue Buffalo Basics",
                amount: 100,
                copperContentPer100g: 0.8,
                timestamp: Date().addingTimeInterval(-7200),
                isLimitedIngredient: true
            ),
            FoodEntry(
                name: "Grain-Free Salmon",
                brand: "Wellness CORE",
                amount: 120,
                copperContentPer100g: 2.1,
                timestamp: Date().addingTimeInterval(-10800),
                isLimitedIngredient: false
            )
        ]
    }
}

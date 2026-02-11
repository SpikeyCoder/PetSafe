import Foundation

// MARK: - USDA Service Protocol
/// Service for estimating copper content in recipes using USDA FoodData Central
protocol USDAService {
    func estimateCopperForRecipe(ingredients: [USDAIngredient]) async throws -> USDARecipeEstimate
    func searchIngredient(query: String) async throws -> [USDAFoodItem]
}

// MARK: - USDA Models
struct USDAIngredient: Codable {
    let name: String
    let grams: Double
    let fdcId: String? // USDA FoodData Central ID

    init(name: String, grams: Double, fdcId: String? = nil) {
        self.name = name
        self.grams = grams
        self.fdcId = fdcId
    }
}

struct USDARecipeEstimate: Codable {
    let title: String
    let copperMgPerServing: Double
    let totalWeight: Double
    let ingredients: [USDAIngredientDetail]
}

struct USDAIngredientDetail: Codable {
    let name: String
    let grams: Double
    let copperMgPer100g: Double
    let copperMgInPortion: Double
}

struct USDAFoodItem: Codable, Identifiable {
    let id: String // fdcId
    let description: String
    let copperMgPer100g: Double?
    let dataType: String?

    var displayName: String {
        description
    }
}

// MARK: - Real USDA Service Implementation
final class USDAServiceImpl: USDAService {
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func estimateCopperForRecipe(ingredients: [USDAIngredient]) async throws -> USDARecipeEstimate {
        var details: [USDAIngredientDetail] = []
        var totalCopper: Double = 0

        for ingredient in ingredients {
            // If we have fdcId, use it to get accurate data
            if let fdcId = ingredient.fdcId {
                let copperContent = try await fetchCopperContent(fdcId: fdcId)
                let copperInPortion = (copperContent * ingredient.grams) / 100.0
                totalCopper += copperInPortion

                details.append(USDAIngredientDetail(
                    name: ingredient.name,
                    grams: ingredient.grams,
                    copperMgPer100g: copperContent,
                    copperMgInPortion: copperInPortion
                ))
            } else {
                // Fallback: estimate based on ingredient name
                let estimate = estimateCopperByName(ingredient.name)
                let copperInPortion = (estimate * ingredient.grams) / 100.0
                totalCopper += copperInPortion

                details.append(USDAIngredientDetail(
                    name: ingredient.name,
                    grams: ingredient.grams,
                    copperMgPer100g: estimate,
                    copperMgInPortion: copperInPortion
                ))
            }
        }

        let totalWeight = ingredients.reduce(0) { $0 + $1.grams }

        return USDARecipeEstimate(
            title: "Recipe Estimate",
            copperMgPerServing: totalCopper,
            totalWeight: totalWeight,
            ingredients: details
        )
    }

    func searchIngredient(query: String) async throws -> [USDAFoodItem] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/foods/search?query=\(encodedQuery)&api_key=\(apiKey)&pageSize=10")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(USDASearchResponse.self, from: data)

        return response.foods
    }

    private func fetchCopperContent(fdcId: String) async throws -> Double {
        let url = URL(string: "\(baseURL)/food/\(fdcId)?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let food = try decoder.decode(USDAFoodDetail.self, from: data)

        // Look for copper in nutrients (nutrient ID 1098 is copper)
        if let copperNutrient = food.foodNutrients.first(where: { $0.nutrientId == 1098 }) {
            return copperNutrient.amount ?? 0
        }

        return 0
    }

    /// Rough estimation based on common ingredient types
    private func estimateCopperByName(_ name: String) -> Double {
        let lower = name.lowercased()
        if lower.contains("liver") || lower.contains("organ") {
            return 5.0 // mg per 100g - high
        } else if lower.contains("shellfish") || lower.contains("oyster") {
            return 7.0 // mg per 100g - very high
        } else if lower.contains("beef") || lower.contains("lamb") {
            return 0.8 // mg per 100g
        } else if lower.contains("chicken") || lower.contains("poultry") {
            return 0.3 // mg per 100g - low
        } else if lower.contains("fish") || lower.contains("salmon") {
            return 0.5 // mg per 100g
        } else if lower.contains("rice") || lower.contains("grain") {
            return 0.2 // mg per 100g - very low
        } else {
            return 0.4 // mg per 100g - default moderate estimate
        }
    }
}

// MARK: - Mock Implementation for Testing
final class USDAServiceMock: USDAService {
    func estimateCopperForRecipe(ingredients: [USDAIngredient]) async throws -> USDARecipeEstimate {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        var details: [USDAIngredientDetail] = []
        var totalCopper: Double = 0

        for ingredient in ingredients {
            let estimate = estimateCopperByName(ingredient.name)
            let copperInPortion = (estimate * ingredient.grams) / 100.0
            totalCopper += copperInPortion

            details.append(USDAIngredientDetail(
                name: ingredient.name,
                grams: ingredient.grams,
                copperMgPer100g: estimate,
                copperMgInPortion: copperInPortion
            ))
        }

        let totalWeight = ingredients.reduce(0) { $0 + $1.grams }

        return USDARecipeEstimate(
            title: "Homemade Recipe (Estimated)",
            copperMgPerServing: totalCopper,
            totalWeight: totalWeight,
            ingredients: details
        )
    }

    func searchIngredient(query: String) async throws -> [USDAFoodItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        let mockItems = [
            USDAFoodItem(id: "1", description: "Chicken breast, raw", copperMgPer100g: 0.3, dataType: "Foundation"),
            USDAFoodItem(id: "2", description: "Beef liver, raw", copperMgPer100g: 5.2, dataType: "Foundation"),
            USDAFoodItem(id: "3", description: "White rice, cooked", copperMgPer100g: 0.15, dataType: "Foundation"),
            USDAFoodItem(id: "4", description: "Salmon, raw", copperMgPer100g: 0.5, dataType: "Foundation")
        ]

        return mockItems.filter { $0.description.localizedCaseInsensitiveContains(query) }
    }

    private func estimateCopperByName(_ name: String) -> Double {
        let lower = name.lowercased()
        if lower.contains("liver") || lower.contains("organ") {
            return 5.0
        } else if lower.contains("shellfish") || lower.contains("oyster") {
            return 7.0
        } else if lower.contains("beef") || lower.contains("lamb") {
            return 0.8
        } else if lower.contains("chicken") || lower.contains("poultry") {
            return 0.3
        } else if lower.contains("fish") || lower.contains("salmon") {
            return 0.5
        } else if lower.contains("rice") || lower.contains("grain") {
            return 0.2
        } else {
            return 0.4
        }
    }
}

// MARK: - Response Models (Private)
private struct USDASearchResponse: Codable {
    let foods: [USDAFoodItem]
}

private struct USDAFoodDetail: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]
}

private struct USDANutrient: Codable {
    let nutrientId: Int
    let amount: Double?
}

// MARK: - Errors
enum USDAError: LocalizedError {
    case invalidAPIKey
    case rateLimitExceeded
    case foodNotFound
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid USDA API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .foodNotFound:
            return "Food item not found in USDA database"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

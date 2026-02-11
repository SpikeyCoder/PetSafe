import Foundation

// MARK: - OpenFoodFacts Service Protocol
/// Service for fetching food product data from OpenFoodFacts API
protocol OpenFoodFactsService {
    func fetchProduct(barcode: String) async throws -> OFFProduct
    func searchProducts(query: String) async throws -> [OFFProduct]
}

// MARK: - OpenFoodFacts Models
struct OFFProduct: Codable, Identifiable {
    let id: String // barcode
    let name: String
    let brand: String?
    let ingredients: [String]
    let copperMgPer100g: Double?
    let imageUrl: String?
    let nutriments: OFFNutriments?

    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name = "product_name"
        case brand = "brands"
        case ingredients = "ingredients_tags"
        case imageUrl = "image_url"
        case nutriments
    }

    init(id: String, name: String, brand: String?, ingredients: [String], copperMgPer100g: Double?, imageUrl: String?, nutriments: OFFNutriments?) {
        self.id = id
        self.name = name
        self.brand = brand
        self.ingredients = ingredients
        self.copperMgPer100g = copperMgPer100g
        self.imageUrl = imageUrl
        self.nutriments = nutriments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients) ?? []
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        nutriments = try container.decodeIfPresent(OFFNutriments.self, forKey: .nutriments)
        
        // Extract copper from nutriments
        copperMgPer100g = nutriments?.copperMg
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(nutriments, forKey: .nutriments)
    }

    var displayBrand: String {
        brand ?? "Unknown Brand"
    }

    var safetyLevel: FoodSafetyLevel {
        guard let copper = copperMgPer100g else { return .caution }
        if copper < 1.0 {
            return .safe
        } else if copper < 2.5 {
            return .caution
        } else {
            return .danger
        }
    }

    var badges: [String] {
        var result: [String] = []
        if let copper = copperMgPer100g {
            if copper < 1.0 {
                result.append("Low Cu")
            } else if copper > 2.5 {
                result.append("High Cu")
            }
        }
        if ingredients.contains(where: { $0.contains("liver") || $0.contains("organ") }) {
            result.append("Organ Meat")
        }
        return result
    }
}

struct OFFNutriments: Codable {
    let copperMg: Double?

    enum CodingKeys: String, CodingKey {
        case copperMg = "copper_100g"
    }
}

// MARK: - Real OpenFoodFacts Service Implementation
final class OpenFoodFactsServiceImpl: OpenFoodFactsService {
    private let baseURL = "https://world.openfoodfacts.org/api/v2"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProduct(barcode: String) async throws -> OFFProduct {
        let url = URL(string: "\(baseURL)/product/\(barcode).json")!
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OFFError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OFFError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OFFProductResponse.self, from: data)

        guard let product = result.product else {
            throw OFFError.productNotFound
        }

        return product
    }

    func searchProducts(query: String) async throws -> [OFFProduct] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/search?search_terms=\(encodedQuery)&json=true")!

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OFFError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw OFFError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OFFSearchResponse.self, from: data)

        return result.products
    }
}

// MARK: - Mock Implementation for Testing
final class OpenFoodFactsServiceMock: OpenFoodFactsService {
    var mockProducts: [OFFProduct] = [
        OFFProduct(
            id: "1234567890",
            name: "Low-Copper Dog Kibble",
            brand: "Hill's Science Diet",
            ingredients: ["chicken", "rice", "vitamins"],
            copperMgPer100g: 0.8,
            imageUrl: nil,
            nutriments: nil
        ),
        OFFProduct(
            id: "0987654321",
            name: "Beef & Liver Mix",
            brand: "Premium Pet Food",
            ingredients: ["beef", "liver", "minerals"],
            copperMgPer100g: 3.2,
            imageUrl: nil,
            nutriments: nil
        )
    ]

    func fetchProduct(barcode: String) async throws -> OFFProduct {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        if let product = mockProducts.first(where: { $0.id == barcode }) {
            return product
        }

        // Return random mock product
        return mockProducts.randomElement() ?? mockProducts[0]
    }

    func searchProducts(query: String) async throws -> [OFFProduct] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return mockProducts.filter { product in
            product.name.localizedCaseInsensitiveContains(query) ||
            product.displayBrand.localizedCaseInsensitiveContains(query)
        }
    }
}

// MARK: - Response Models
private struct OFFProductResponse: Codable {
    let product: OFFProduct?
}

private struct OFFSearchResponse: Codable {
    let products: [OFFProduct]
}

// MARK: - Errors
enum OFFError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case productNotFound
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .productNotFound:
            return "Product not found in database"
        case .decodingError:
            return "Failed to decode product data"
        }
    }
}

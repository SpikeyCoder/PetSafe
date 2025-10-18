import Foundation

public struct OnboardingData: Hashable, Codable {
    public var dogName: String
    public var breed: String
    public var age: Int
    public var weight: Double
    public var healthConditions: [String]
    public var dietaryRestrictions: [String]
    public var primaryConcerns: [String]
    public var vetRecommendations: [String]

    public init(dogName: String, breed: String, age: Int, weight: Double, healthConditions: [String], dietaryRestrictions: [String], primaryConcerns: [String], vetRecommendations: [String]) {
        self.dogName = dogName
        self.breed = breed
        self.age = age
        self.weight = weight
        self.healthConditions = healthConditions
        self.dietaryRestrictions = dietaryRestrictions
        self.primaryConcerns = primaryConcerns
        self.vetRecommendations = vetRecommendations
    }
}

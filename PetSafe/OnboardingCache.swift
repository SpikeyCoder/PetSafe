// OnboardingCache.swift
// Lightweight persistence for onboarding answers and first-login status.

import Foundation

struct OnboardingCache {
    private static let dataKey = "onboarding.data.json"
    private static let completedKey = "onboarding.completed"

    static func save(_ data: OnboardingData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: dataKey)
        }
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    static func load() -> OnboardingData? {
        guard let raw = UserDefaults.standard.data(forKey: dataKey) else { return nil }
        return try? JSONDecoder().decode(OnboardingData.self, from: raw)
    }

    static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: dataKey)
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
}

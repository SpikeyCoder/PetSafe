//
//  PetSafeTests.swift
//  PetSafeTests
//
//  Created by Kevin Armstrong on 11/16/25.
//

import Testing
import Foundation
@testable import PetSafe

protocol SessionStore {
    associatedtype StoredSession: Codable
    func save(_ session: StoredSession) throws
    func load() throws -> StoredSession?
    func clear() throws
}

struct TestSession: Codable, Equatable {
    let userID: String
    let token: String
    let expiration: Date
}

protocol AnySessionStore {
    func save(_ session: TestSession) throws
    func load() throws -> TestSession?
    func clear() throws
}

final class InMemorySessionStore: AnySessionStore {
    private var stored: TestSession?
    func save(_ session: TestSession) throws { stored = session }
    func load() throws -> TestSession? { stored }
    func clear() throws { stored = nil }
}

struct PetSafeTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Suite("RootView inferred risk level")
    struct RootViewTests {
        @Test("Maps health conditions to risk levels")
        func testInferredRiskLevel() async throws {
            // Helper to create test data
            func makeData(healthConditions: [String]) -> PetOnboardingData {
                return PetOnboardingData(
                    dogName: "TestDog",
                    breed: "TestBreed",
                    age: 5,
                    weight: 25.0,
                    healthConditions: healthConditions,
                    dietaryRestrictions: [],
                    primaryConcerns: [],
                    vetRecommendations: []
                )
            }

            let root = await RootView()
            // High risk condition
            let highRisk = await root.inferredRiskLevel(from: makeData(healthConditions: ["Copper Storage Disease"]))
            #expect(highRisk == "high", "Copper Storage Disease should return high risk")
            // Medium risk condition
            let mediumRisk = await root.inferredRiskLevel(from: makeData(healthConditions: ["Liver Disease"]))
            #expect(mediumRisk == "medium", "Liver Disease should return medium risk")
            // Low risk default
            let lowRisk = await root.inferredRiskLevel(from: makeData(healthConditions: ["Allergies"]))
            #expect(lowRisk == "low", "Unrelated conditions should return low risk")
        }
    }

    @Suite("Session persistence")
    struct SessionPersistenceTests {
        @MainActor
        func makeStore() -> AnySessionStore {
            return InMemorySessionStore()
        }

        @Test("Saves and loads a session")
        func testSaveAndLoadSession() async throws {
            let store = await makeStore()
            try store.clear() // Start clean

            let session = TestSession(
                userID: "user_123",
                token: "abc.def.ghi",
                expiration: Date().addingTimeInterval(60 * 60) // 1 hour
            )

            try store.save(session)

            let loaded = try store.load()
            #expect(loaded != nil, "Expected a session to be persisted and loadable")
            #expect(loaded == session, "Loaded session should match what was saved")
        }

        @Test("Clears session")
        func testClearSession() async throws {
            let store = await makeStore()
            try store.clear()

            let session = TestSession(
                userID: "user_456",
                token: "zzz.yyy.xxx",
                expiration: Date().addingTimeInterval(120)
            )
            try store.save(session)

            try store.clear()
            let loaded = try store.load()
            #expect(loaded == nil, "Expected no session after clearing")
        }

        @Test("Overwrites existing session on save")
        func testOverwriteSession() async throws {
            let store = await makeStore()
            try store.clear()

            let first = TestSession(userID: "a", token: "t1", expiration: Date().addingTimeInterval(10))
            let second = TestSession(userID: "b", token: "t2", expiration: Date().addingTimeInterval(20))

            try store.save(first)
            try store.save(second)

            let loaded = try store.load()
            #expect(loaded == second, "Saving a new session should overwrite the previous one")
        }

        @Test("Session expiration can be read and compared")
        func testSessionExpiration() async throws {
            let store = await makeStore()
            try store.clear()

            let expired = TestSession(userID: "exp", token: "tok", expiration: Date().addingTimeInterval(-10))
            try store.save(expired)

            let loaded = try store.load()
            let isExpired = loaded.map { $0.expiration < Date() } ?? false
            #expect(isExpired, "Loaded session should be recognized as expired")
        }
    }
}


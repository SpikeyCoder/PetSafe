import Foundation
internal import Combine
import SwiftUI
import SwiftData

// MARK: - Food Log ViewModel
/// Manages food entries and daily copper tracking
@MainActor
final class FoodLogViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var entries: [FoodEntry] = []
    @Published var selectedDate: Date = Date()
    @Published var showingAddSheet = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let dogProfile: DogProfile?

    // MARK: - Computed Properties
    var todaysEntries: [FoodEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: selectedDate)
        }
    }

    var totalCopperToday: Double {
        todaysEntries.reduce(0) { $0 + $1.totalCopperContent }
    }

    var totalWeightToday: Double {
        todaysEntries.reduce(0) { $0 + $1.amount }
    }

    var copperPercentage: Double {
        guard let dailyLimit = dogProfile?.dailyCopperLimit, dailyLimit > 0 else {
            return 0
        }
        return min((totalCopperToday / dailyLimit) * 100, 100)
    }

    var copperStatus: SafetyLevel {
        if copperPercentage < 70 {
            return .safe
        } else if copperPercentage < 90 {
            return .caution
        } else {
            return .danger
        }
    }

    var remainingCopper: Double {
        guard let dailyLimit = dogProfile?.dailyCopperLimit else { return 0 }
        return max(dailyLimit - totalCopperToday, 0)
    }

    // MARK: - Initialization
    init(modelContext: ModelContext, dogProfile: DogProfile?) {
        self.modelContext = modelContext
        self.dogProfile = dogProfile
        loadEntries()
    }

    // MARK: - Data Operations
    func loadEntries() {
        do {
            let descriptor = FetchDescriptor<FoodEntry>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            entries = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load food entries: \(error.localizedDescription)"
            print("Error loading entries: \(error)")
        }
    }

    func addEntry(
        name: String,
        brand: String,
        amount: Double,
        copperContentPer100g: Double,
        isLimitedIngredient: Bool = false,
        barcode: String? = nil,
        notes: String? = nil
    ) {
        let entry = FoodEntry(
            name: name,
            brand: brand,
            amount: amount,
            copperContentPer100g: copperContentPer100g,
            timestamp: Date(),
            isLimitedIngredient: isLimitedIngredient,
            barcode: barcode,
            notes: notes,
            dogProfile: dogProfile
        )

        modelContext.insert(entry)
        saveContext()
        loadEntries()
    }

    func addEntryFromScan(_ product: ScannedProduct, amount: Double) {
        addEntry(
            name: product.name,
            brand: product.brand,
            amount: amount,
            copperContentPer100g: product.copperMgPer100g,
            isLimitedIngredient: false,
            barcode: product.barcode,
            notes: product.isEstimated ? "Estimated copper content" : nil
        )
    }

    func updateEntry(_ entry: FoodEntry, amount: Double? = nil, notes: String? = nil) {
        if let amount = amount {
            entry.amount = amount
        }
        if let notes = notes {
            entry.notes = notes
        }
        saveContext()
        loadEntries()
    }

    func deleteEntry(_ entry: FoodEntry) {
        modelContext.delete(entry)
        saveContext()
        loadEntries()
    }

    func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = todaysEntries[index]
            modelContext.delete(entry)
        }
        saveContext()
        loadEntries()
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Date Navigation
    func selectPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay
        }
    }

    func selectNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay
        }
    }

    func selectToday() {
        selectedDate = Date()
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    // MARK: - Statistics
    func entriesForWeek() -> [FoodEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return entries.filter { $0.timestamp >= weekAgo }
    }

    func averageDailyCopper(days: Int = 7) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        let recentEntries = entries.filter { $0.timestamp >= startDate }

        guard !recentEntries.isEmpty else { return 0 }

        let totalCopper = recentEntries.reduce(0) { $0 + $1.totalCopperContent }
        return totalCopper / Double(days)
    }

    // MARK: - Private Methods
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Preview Helper
extension FoodLogViewModel {
    static var preview: FoodLogViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: FoodEntry.self, DogProfile.self, configurations: config)
        let context = container.mainContext

        // Create sample profile
        let profile = DogProfile.sampleProfile
        context.insert(profile)

        // Create sample entries
        let entries = FoodEntry.sampleEntries
        entries.forEach { entry in
            entry.dogProfile = profile
            context.insert(entry)
        }

        return FoodLogViewModel(modelContext: context, dogProfile: profile)
    }
}

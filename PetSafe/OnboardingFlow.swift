import SwiftUI

struct PetOnboardingData: Equatable {
    var dogName: String = ""
    var breed: String = ""
    var age: Int = 0
    var weight: Double = 0
    var healthConditions: [String] = []
    var dietaryRestrictions: [String] = []
    var primaryConcerns: [String] = []
    var vetRecommendations: [String] = []
}

struct OnboardingFlow: View {
    let onComplete: (PetOnboardingData) -> Void
    let onBackToLogin: () -> Void

    @State private var step: Int = 0
    @State private var ageText: String = ""
    @State private var weightText: String = ""
    private let totalSteps = 7

    @State var data = PetOnboardingData(
        dogName: "",
        breed: "",
        age: 0,
        weight: 0,
        healthConditions: [],
        dietaryRestrictions: [],
        primaryConcerns: [],
        vetRecommendations: []
    )

    private let breeds = [
        "Mixed Breed", "Labrador Retriever", "Golden Retriever", "German Shepherd",
        "Bulldog", "Poodle", "Beagle", "Rottweiler", "Yorkshire Terrier", "Dachshund",
        "Siberian Husky", "Other"
    ]
    private let healthConditions = [
        "Copper Storage Disease", "Liver Disease", "Wilson's Disease",
        "Chronic Hepatitis", "Kidney Disease", "Food Allergies",
        "Digestive Issues"
    ]
    private let dietaryRestrictions = [
        "Grain-free diet", "Limited ingredient diet", "Raw food diet",
        "Prescription diet", "Low-copper diet", "Hypoallergenic diet",
        "Senior dog formula"
    ]
    private let primaryConcerns = [
        "Copper toxicity prevention", "Liver health monitoring", "Weight management",
        "Food allergies", "Digestive health", "Senior dog care",
        "Breed-specific health risks", "General wellness tracking"
    ]
    private let vetRecommendations = [
        "Monitor copper intake", "Avoid high-copper foods", "Regular liver function tests",
        "Specific diet recommendations", "Monitor weight", "Track symptoms"
    ]

    var progress: Double { Double(step + 1) / Double(totalSteps) * 100.0 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Welcome to PetSafe").font(.title2.weight(.semibold))
                    Text("Let's personalize your experience with \(data.dogName.isEmpty ? "your dog" : data.dogName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ProgressView(value: progress, total: 100)
                        .tint(.orange)
                        .padding(.top, 8)
                }
                .padding(.horizontal)

                Group { currentStepView() }
                    .padding(.horizontal)

                HStack {
                    Button {
                        sanitizeSelections()
                        if step == 0 { onBackToLogin() } else { step -= 1 }
                    } label: {
                        Label(step == 0 ? "Back to Login" : "Back", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        // Commit numeric fields when leaving step 2
                        if step == 2 {
                            let age = Int(ageText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                            let weight = Int(weightText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                            data.age = age
                            data.weight = Double(weight)
                        }
                        sanitizeSelections()
                        if step < totalSteps - 1 { step += 1 } else { onComplete(data) }
                    } label: {
                        HStack {
                            Text(step == totalSteps - 1 ? "Get Started" : "Next")
                            if step < totalSteps - 1 { Image(systemName: "chevron.right") }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(!canProceed())
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Onboarding")
        }
    }

    @ViewBuilder private func currentStepView() -> some View {
        switch step {
        case 0:
            VStack(alignment: .leading, spacing: 12) {
                Text("Dog's Name").font(.headline)
                TextField("Enter your dog's name", text: $data.dogName)
                    .textFieldStyle(.roundedBorder)
            }
        case 1:
            VStack(alignment: .leading, spacing: 12) {
                Text("Breed").font(.headline)
                Picker("Select your dog's breed", selection: $data.breed) {
                    Text("None").tag(nil as [String]?)
                    ForEach(breeds, id: \.self) { breed in
                        Text(breed).tag(breed)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        case 2:
            VStack(alignment: .leading, spacing: 12) {
                Text("Age").font(.headline)
                TextField("Enter your dog's age (years)", text: $ageText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: ageText) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue { ageText = filtered }
                        data.age = Int(filtered) ?? 0
                    }

                Text("Weight").font(.headline)
                TextField("Enter your dog's weight (lbs)", text: $weightText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: weightText) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue { weightText = filtered }
                        data.weight = Double(Int(filtered) ?? 0)
                    }
            }
            .onAppear {
                // Pre-fill when returning to this step
                if ageText.isEmpty { ageText = data.age == 0 ? "" : String(data.age) }
                if weightText.isEmpty { weightText = data.weight == 0 ? "" : String(data.weight) }
            }
        case 3:
            checkboxList(
                title: "Health Conditions",
                subtitle: "Select any known health conditions",
                items: healthConditions,
                selection: $data.healthConditions
            )
        case 4:
            checkboxList(
                title: "Dietary Restrictions",
                subtitle: "Select any dietary restrictions or preferences",
                items: dietaryRestrictions,
                selection: $data.dietaryRestrictions
            )
        case 5:
            checkboxList(
                title: "Primary Concerns",
                subtitle: "Select your primary monitoring concerns",
                items: primaryConcerns,
                selection: $data.primaryConcerns
            )
        case 6:
            checkboxList(
                title: "Veterinary Recommendations",
                subtitle: "Select veterinarian recommendations if any",
                items: vetRecommendations,
                selection: $data.vetRecommendations
            )
        default:
            EmptyView()
        }
    }

    private func sanitizeSelections() {
        let stringToRemove = "test"
        data.healthConditions.removeAll { $0 == stringToRemove }
        data.dietaryRestrictions.removeAll { $0 == stringToRemove }
        data.vetRecommendations.removeAll { $0 == stringToRemove }
        data.primaryConcerns.removeAll { $0 == stringToRemove }
    }

    private func canProceed() -> Bool {
        switch step {
        case 0: return !data.dogName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        case 1: return !data.breed.isEmpty
        case 2: return (Int(ageText) ?? 0) > 0 && (Int(weightText) ?? 0) > 0
        case 3: return !data.healthConditions.isEmpty
        case 4: return !data.dietaryRestrictions.isEmpty
        case 5: return !data.primaryConcerns.isEmpty
        case 6: return !data.vetRecommendations.isEmpty
        default: return true
        }
    }

    @ViewBuilder private func checkboxList(title: String, subtitle: String, items: [String], selection: Binding<[String]>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            ForEach(items, id: \.self) { item in
                Toggle(isOn: Binding(
                    get: { selection.wrappedValue.contains(item) },
                    set: { checked in
                        if checked {
                            if !selection.wrappedValue.contains(item) {
                                selection.wrappedValue.append(item)
                            }
                        } else {
                            selection.wrappedValue.removeAll { $0 == item }
                        }
                    }
                )) {
                    Text(item)
                }
                .toggleStyle(.switch)
            }
        }
    }
}

#Preview {
    OnboardingFlow(
        onComplete: { data in print("Completed with data: \(data)") },
        onBackToLogin: { print("Back to login tapped") }
    )
}

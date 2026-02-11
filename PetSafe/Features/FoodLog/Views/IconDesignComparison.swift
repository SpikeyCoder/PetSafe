import SwiftUI

// MARK: - Icon Design Comparison
/// Interactive comparison view to help you choose the best icon design
/// Run this preview to see all designs side-by-side

struct IconDesignComparison: View {
    @State private var selectedDesign = 0
    @State private var iconSize: CGFloat = 180
    
    let designs = [
        ("Default", "Shield with paw accent - balanced design", Color.blue),
        ("Minimal", "Clean shield only - professional", Color.green),
        ("Chemical", "Cu symbol in shield - scientific", Color.purple),
        ("Paw Focus", "Pet-first with badge - friendly", Color.orange)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your App Icon")
                            .font(.title.bold())
                        
                        Text("Select the design that best represents your brand")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Size selector
                    VStack(spacing: 12) {
                        Text("Preview Size")
                            .font(.headline)
                        
                        Picker("Size", selection: $iconSize) {
                            Text("Small (60pt)").tag(CGFloat(60))
                            Text("Medium (120pt)").tag(CGFloat(120))
                            Text("Large (180pt)").tag(CGFloat(180))
                            Text("Extra Large (300pt)").tag(CGFloat(300))
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // Large preview of selected design
                    VStack(spacing: 16) {
                        iconForDesign(selectedDesign, size: 280)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 4) {
                            Text(designs[selectedDesign].0)
                                .font(.title2.weight(.semibold))
                            
                            Text(designs[selectedDesign].1)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    // Design selector
                    VStack(spacing: 16) {
                        Text("Choose Design")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(0..<4) { index in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedDesign = index
                                    }
                                } label: {
                                    VStack(spacing: 12) {
                                        iconForDesign(index, size: 120)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 27)
                                                    .stroke(
                                                        selectedDesign == index ? designs[index].2 : Color.clear,
                                                        lineWidth: 4
                                                    )
                                            )
                                            .shadow(radius: selectedDesign == index ? 10 : 5)
                                            .scaleEffect(selectedDesign == index ? 1.05 : 1.0)
                                        
                                        Text(designs[index].0)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(selectedDesign == index ? designs[index].2 : .primary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Context preview
                    VStack(spacing: 16) {
                        Text("In Context")
                            .font(.headline)
                        
                        // Home screen preview
                        contextPreview(title: "Home Screen")
                        
                        // Settings preview
                        contextPreviewSmall(title: "Settings")
                    }
                    .padding()
                    
                    // Export instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Next Steps", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            instructionStep(number: 1, text: "Choose your preferred design above")
                            instructionStep(number: 2, text: "Open AppIconGenerator.swift")
                            instructionStep(number: 3, text: "Run the preview for your chosen design")
                            instructionStep(number: 4, text: "Screenshot at 1024×1024 size")
                            instructionStep(number: 5, text: "Add to Assets.xcassets in Xcode")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Design rationale
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Design Details")
                            .font(.headline)
                        
                        designRationale(
                            icon: "shield.checkerboard",
                            title: "Shield Symbol",
                            description: "Represents safety and protection, the core value of PetSafe"
                        )
                        
                        designRationale(
                            icon: "pawprint.fill",
                            title: "Paw Print",
                            description: "Instantly communicates that this is a pet-focused application"
                        )
                        
                        designRationale(
                            icon: "paintpalette.fill",
                            title: "Orange Gradient",
                            description: "Brand colors that convey warmth, energy, and attention"
                        )
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("App Icon Designer")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func iconForDesign(_ index: Int, size: CGFloat) -> some View {
        Group {
            switch index {
            case 0:
                AppIconGenerator(size: size)
            case 1:
                AppIconMinimal(size: size)
            case 2:
                AppIconChemical(size: size)
            case 3:
                AppIconPaw(size: size)
            default:
                AppIconGenerator(size: size)
            }
        }
        .cornerRadius(size * 0.225)
    }
    
    private func contextPreview(title: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                // Simulated home screen
                VStack(spacing: 8) {
                    iconForDesign(selectedDesign, size: iconSize)
                        .shadow(radius: 3)
                    
                    Text("PetSafe")
                        .font(.caption)
                        .lineLimit(1)
                }
                
                iconForDesign(selectedDesign, size: iconSize)
                    .shadow(radius: 3)
                
                iconForDesign(selectedDesign, size: iconSize)
                    .shadow(radius: 3)
                    .opacity(0.5) // Simulate other apps
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func contextPreviewSmall(title: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                iconForDesign(selectedDesign, size: 44)
                    .shadow(radius: 2)
                
                VStack(alignment: .leading) {
                    Text("PetSafe")
                        .font(.subheadline.weight(.semibold))
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func instructionStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Theme.Colors.orange600)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
    
    private func designRationale(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.Colors.orange600)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Side-by-Side Comparison
/// Simple grid view comparing all designs
struct IconGridComparison: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("App Icon Designs")
                    .font(.title.bold())
                    .padding(.top)
                
                // All designs at large size
                VStack(spacing: 32) {
                    designCard(
                        title: "Default Design",
                        subtitle: "Shield with paw accent",
                        icon: AnyView(AppIconGenerator(size: 200))
                    )
                    
                    designCard(
                        title: "Minimal Design",
                        subtitle: "Clean shield only",
                        icon: AnyView(AppIconMinimal(size: 200))
                    )
                    
                    designCard(
                        title: "Chemical Design",
                        subtitle: "Cu symbol in shield",
                        icon: AnyView(AppIconChemical(size: 200))
                    )
                    
                    designCard(
                        title: "Paw Focus Design",
                        subtitle: "Pet-first with badge",
                        icon: AnyView(AppIconPaw(size: 200))
                    )
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func designCard(title: String, subtitle: String, icon: AnyView) -> some View {
        VStack(spacing: 16) {
            icon
                .cornerRadius(45)
                .shadow(radius: 10)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

// MARK: - Previews
#Preview("Interactive Comparison") {
    IconDesignComparison()
}

#Preview("Grid Comparison") {
    IconGridComparison()
}

import SwiftUI

// MARK: - App Icon Preview Generator
/// Use this view to generate a visual preview of your app icon
/// Take screenshots at different sizes and export as PNG for your app icon assets

struct AppIconGenerator: View {
    var size: CGFloat = 1024
    var showGuides: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: size * 0.225) // iOS icon corner radius is ~22.5%
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.orange500,
                            Theme.Colors.orange600
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Subtle inner shadow effect (optional)
            RoundedRectangle(cornerRadius: size * 0.225)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.8
                    )
                )
            
            // Main shield icon
            Image(systemName: "shield.checkerboard")
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: size * 0.02, x: 0, y: size * 0.01)
            
            // Small paw accent in bottom-right
            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.16))
                .foregroundStyle(.white.opacity(0.9))
                .offset(x: size * 0.18, y: size * 0.16)
                .shadow(color: .black.opacity(0.15), radius: size * 0.015)
            
            // Optional: Guide lines for debugging
            if showGuides {
                Path { path in
                    path.move(to: CGPoint(x: size / 2, y: 0))
                    path.addLine(to: CGPoint(x: size / 2, y: size))
                    path.move(to: CGPoint(x: 0, y: size / 2))
                    path.addLine(to: CGPoint(x: size, y: size / 2))
                }
                .stroke(Color.blue, lineWidth: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Alternative Icon Designs

/// Alternative design: Minimal with just shield
struct AppIconMinimal: View {
    var size: CGFloat = 1024
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.225)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.orange500,
                            Theme.Colors.orange600
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Image(systemName: "shield.checkerboard")
                .font(.system(size: size * 0.6, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

/// Alternative design: Chemical symbol "Cu" in shield
struct AppIconChemical: View {
    var size: CGFloat = 1024
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.225)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.orange500,
                            Theme.Colors.orange600
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Shield background
            Image(systemName: "shield.fill")
                .font(.system(size: size * 0.7, weight: .medium))
                .foregroundStyle(.white)
            
            // "Cu" text
            Text("Cu")
                .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.orange600)
        }
        .frame(width: size, height: size)
    }
}

/// Alternative design: Paw with safety badge
struct AppIconPaw: View {
    var size: CGFloat = 1024
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.225)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.orange500,
                            Theme.Colors.orange600
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Large paw print
            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            
            // Small shield badge
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "shield.fill")
                        .font(.system(size: size * 0.18))
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .fill(Theme.Colors.orange700)
                                .frame(width: size * 0.25, height: size * 0.25)
                        )
                        .padding(size * 0.08)
                }
                Spacer()
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Icon Size Previews
/// Shows all required icon sizes in context
struct AppIconSizePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("App Icon Sizes")
                    .font(.title.bold())
                    .padding(.top)
                
                // Settings Icon (40pt)
                iconPreviewRow(title: "Settings (40pt @3x = 120px)", size: 120)
                
                // App Icon (60pt)
                iconPreviewRow(title: "Home Screen (60pt @3x = 180px)", size: 180)
                
                // iPad Icon (76pt)
                iconPreviewRow(title: "iPad (76pt @2x = 152px)", size: 152)
                
                // iPad Pro Icon
                iconPreviewRow(title: "iPad Pro (83.5pt @2x = 167px)", size: 167)
                
                // App Store Icon
                iconPreviewRow(title: "App Store (1024pt = 1024px)", size: 200)
                    .padding(.bottom, 32)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func iconPreviewRow(title: String, size: CGFloat) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            AppIconGenerator(size: size)
                .background(Color.white)
                .cornerRadius(size * 0.225)
                .shadow(radius: 5)
        }
    }
}

// MARK: - Batch Export View
/// Export view to generate all required sizes at once
struct AppIconBatchExport: View {
    let sizes: [(name: String, size: CGFloat)] = [
        ("Settings 2x", 80),
        ("Settings 3x", 120),
        ("App 2x", 120),
        ("App 3x", 180),
        ("iPad", 152),
        ("iPad Pro", 167),
        ("App Store", 1024)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 32) {
                ForEach(sizes, id: \.name) { item in
                    VStack(spacing: 8) {
                        AppIconGenerator(size: 200) // Preview size
                            .cornerRadius(45)
                            .shadow(radius: 5)
                        
                        Text(item.name)
                            .font(.caption.weight(.semibold))
                        
                        Text("\(Int(item.size))×\(Int(item.size))px")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Previews
#Preview("Main Icon") {
    AppIconGenerator(size: 1024)
        .background(Color.gray.opacity(0.2))
}

#Preview("Main Icon - Small") {
    AppIconGenerator(size: 180)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Alternative - Minimal") {
    AppIconMinimal(size: 512)
        .background(Color.gray.opacity(0.2))
}

#Preview("Alternative - Chemical") {
    AppIconChemical(size: 512)
        .background(Color.gray.opacity(0.2))
}

#Preview("Alternative - Paw") {
    AppIconPaw(size: 512)
        .background(Color.gray.opacity(0.2))
}

#Preview("All Sizes") {
    AppIconSizePreview()
}

#Preview("Batch Export") {
    AppIconBatchExport()
}

import SwiftUI

// MARK: - Loading Screen
/// Displays during app initialization with animated logo and branding
struct LoadingScreen: View {
    @State private var isAnimating = false
    @State private var fadeIn = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Theme.Colors.orange50,
                    Theme.Colors.orange100,
                    .white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // App icon/logo
                ZStack {
                    // Outer glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.Colors.orange200.opacity(0.6),
                                    Theme.Colors.orange100.opacity(0.3),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.8)
                    
                    // Main icon background
                    Circle()
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
                        .frame(width: 120, height: 120)
                        .shadow(color: Theme.Colors.orange600.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    // Icon content
                    VStack(spacing: 4) {
                        // Shield/paw icon
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        // Small paw accent
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.9))
                            .offset(x: 20, y: -10)
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(fadeIn ? 1 : 0)
                
                // App name
                VStack(spacing: Theme.Spacing.xs) {
                    Text("PetSafe")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.orange700,
                                    Theme.Colors.orange600
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Copper Safety Tracker")
                        .font(Theme.Typography.callout)
                        .foregroundStyle(Theme.Colors.orange800.opacity(0.8))
                        .tracking(1.5)
                }
                .opacity(fadeIn ? 1 : 0)
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: Theme.Spacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.orange600))
                        .scaleEffect(1.2)
                    
                    Text("Loading your dog's profile...")
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(fadeIn ? 1 : 0)
                .padding(.bottom, Theme.Spacing.xxxl)
            }
        }
        .onAppear {
            // Animate on appear
            withAnimation(.easeOut(duration: 0.6)) {
                fadeIn = true
                isAnimating = true
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Alternative Loading Screen (Minimal)
/// Simpler loading screen variant with just logo and spinner
struct LoadingScreenMinimal: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xxl) {
                // Logo
                ZStack {
                    Circle()
                        .fill(Theme.Colors.orange600)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "shield.checkerboard")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                // Spinner
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.orange600))
            }
        }
    }
}

// MARK: - Preview
#Preview("Loading Screen - Full") {
    LoadingScreen()
}

#Preview("Loading Screen - Minimal") {
    LoadingScreenMinimal()
}

import SwiftUI

// MARK: - Theme System
/// Centralized design system for PetSafe app
/// Based on Tailwind-inspired color palette with consistent spacing and typography

enum Theme {
    // MARK: - Colors
    enum Colors {
        // Orange (Primary/Brand)
        static let orange50 = Color(red: 1.0, green: 0.973, blue: 0.941)
        static let orange100 = Color(red: 1.0, green: 0.945, blue: 0.89)
        static let orange200 = Color(red: 0.996, green: 0.894, blue: 0.78)
        static let orange500 = Color(red: 0.96, green: 0.48, blue: 0.24)
        static let orange600 = Color(red: 0.89, green: 0.38, blue: 0.18)
        static let orange700 = Color(red: 0.78, green: 0.29, blue: 0.12)
        static let orange800 = Color(red: 0.64, green: 0.22, blue: 0.09)
        static let orange900 = Color(red: 0.55, green: 0.18, blue: 0.05)

        // Blue (Info/Profile)
        static let blue50 = Color(red: 0.949, green: 0.965, blue: 0.996)
        static let blue200 = Color(red: 0.8, green: 0.86, blue: 0.98)
        static let blue600 = Color(red: 0.15, green: 0.35, blue: 0.85)

        // Green (Safe/Success)
        static let green50 = Color(red: 0.941, green: 0.973, blue: 0.953)
        static let green200 = Color(red: 0.8, green: 0.92, blue: 0.83)
        static let green500 = Color(red: 0.2, green: 0.7, blue: 0.4)
        static let green600 = Color(red: 0.12, green: 0.6, blue: 0.3)

        // Yellow (Caution/Warning)
        static let yellow50 = Color(red: 1.0, green: 0.98, blue: 0.9)
        static let yellow200 = Color(red: 0.98, green: 0.9, blue: 0.6)
        static let yellow500 = Color(red: 0.95, green: 0.75, blue: 0.2)
        static let yellow600 = Color(red: 0.85, green: 0.65, blue: 0.1)

        // Red (Danger/Avoid)
        static let red50 = Color(red: 1.0, green: 0.94, blue: 0.94)
        static let red200 = Color(red: 0.98, green: 0.8, blue: 0.8)
        static let red500 = Color(red: 0.9, green: 0.2, blue: 0.2)
        static let red600 = Color(red: 0.8, green: 0.1, blue: 0.1)

        // Semantic Colors
        static let primaryBrand = orange600
        static let safeGreen = green600
        static let warningYellow = yellow600
        static let dangerRed = red600
    }

    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Custom styles
        static func customTitle(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            Font.system(size: size, weight: weight)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 10
        static let lg: CGFloat = 12
        static let xl: CGFloat = 14
    }

    // MARK: - Shadow
    enum Shadow {
        static let sm = 2.0
        static let md = 4.0
        static let lg = 8.0
    }
}



// MARK: - View Extensions for Common Styles
extension View {
    /// Apply card style with standard padding, background, and border
    func cardStyle(backgroundColor: Color = Color(.systemBackground), borderColor: Color = Color.gray.opacity(0.15)) -> some View {
        self
            .padding(Theme.Spacing.md)
            .background(backgroundColor)
            .overlay(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg).stroke(borderColor, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    /// Apply badge style
    func badgeStyle(backgroundColor: Color, foregroundColor: Color = .primary) -> some View {
        self
            .font(Theme.Typography.caption)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
    }

    /// Apply premium badge style
    func premiumBadge() -> some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.caption2)
            self
        }
        .font(Theme.Typography.caption.weight(.semibold))
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(Theme.Colors.orange600)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = Theme.Colors.orange600
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            configuration.label
        }
        .font(Theme.Typography.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Status Colors Helper
enum SafetyLevel {
    case safe
    case caution
    case danger

    var color: Color {
        switch self {
        case .safe: return Theme.Colors.safeGreen
        case .caution: return Theme.Colors.warningYellow
        case .danger: return Theme.Colors.dangerRed
        }
    }

    var backgroundColor: Color {
        switch self {
        case .safe: return Theme.Colors.green50
        case .caution: return Theme.Colors.yellow50
        case .danger: return Theme.Colors.red50
        }
    }

    var borderColor: Color {
        switch self {
        case .safe: return Theme.Colors.green200
        case .caution: return Theme.Colors.yellow200
        case .danger: return Theme.Colors.red200
        }
    }

    var iconName: String {
        switch self {
        case .safe: return "checkmark.circle"
        case .caution: return "exclamationmark.triangle"
        case .danger: return "xmark.octagon"
        }
    }

    var text: String {
        switch self {
        case .safe: return "Safe"
        case .caution: return "Caution"
        case .danger: return "Danger"
        }
    }
}

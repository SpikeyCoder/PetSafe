import SwiftUI
import SwiftData

// MARK: - Dashboard View
/// Main app dashboard with tabs for home, scanner, and food log
struct DashboardView: View {
    // ViewModels
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @ObservedObject var scannerViewModel: ScannerViewModel
    @ObservedObject var foodLogViewModel: FoodLogViewModel

    // State
    @State private var selectedTab: DashboardTab = .home
    @State private var showingScanner = false
    @State private var showingSettings = false
    @State private var showingLogoutConfirmation = false

    // Dog profile from environment
    @Query private var profiles: [DogProfile]
    private var dogProfile: DogProfile? { profiles.first }

    // Logout callback
    var onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom tab bar
                tabBar

                Divider()

                // Tab content
                TabView(selection: $selectedTab) {
                    homeTab
                        .tag(DashboardTab.home)

                    scannerTab
                        .tag(DashboardTab.scan)

                    logTab
                        .tag(DashboardTab.log)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.Colors.orange600)
                    }
                    .accessibleButton(
                        label: "Settings",
                        hint: "Open settings and account options"
                    )
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(
                    subscriptionViewModel: subscriptionViewModel,
                    onLogout: {
                        showingSettings = false
                        showingLogoutConfirmation = true
                    }
                )
            }
            .sheet(isPresented: $subscriptionViewModel.showPaywall) {
                PaywallView(viewModel: subscriptionViewModel)
            }
            .sheet(isPresented: $showingScanner) {
                NavigationStack {
                    BarcodeScannerView(viewModel: scannerViewModel)
                }
            }
            .onChange(of: scannerViewModel.scanState) { oldValue, newValue in
                // Auto-add scanned products to food log
                if case .found(_) = newValue,
                   subscriptionViewModel.isPremium {
                    // Product found - user will add manually from ProductResultView
                }
            }
            .confirmationDialog("Log Out", isPresented: $showingLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    onLogout()
                }
                .accessibilityIdentifier("confirm_logout_button")
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            tabButton(.home, icon: "house.fill", title: "Home")
            tabButton(.scan, icon: "barcode.viewfinder", title: "Scan")
            tabButton(.log, icon: "clock.arrow.circlepath", title: "Log")
        }
        .padding(Theme.Spacing.sm)
        .background(Color(.secondarySystemBackground))
    }

    private func tabButton(_ tab: DashboardTab, icon: String, title: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                if selectedTab == tab {
                    Text(title)
                        .font(Theme.Typography.subheadline.weight(.semibold))
                }
            }
            .foregroundStyle(selectedTab == tab ? .white : .primary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                selectedTab == tab ? Theme.Colors.orange600 : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(title)Tab")
        .accessibilityLabel(title)
    }

    // MARK: - Home Tab
    private var homeTab: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header with logout
                homeHeader

                // Premium upgrade banner
                PremiumUpgradeBanner(viewModel: subscriptionViewModel)

                // Dog profile card
                if let profile = dogProfile {
                    dogProfileCard(profile)
                }

                // Today's copper status
                todaysCopperCard

                // Quick actions
                quickActionsCard

                // Recent insights
                insightsCard

                // Settings and logout section
                settingsSection
            }
            .padding()
        }
    }

    // MARK: - Home Header
    private var homeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let profile = dogProfile {
                    Text("Welcome back!")
                        .font(Theme.Typography.title)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("welcome_message")

                    Text("Protecting \(profile.name)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("PetSafe")
                        .font(Theme.Typography.title)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            Button {
                showingLogoutConfirmation = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .font(Theme.Typography.subheadline)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Colors.orangeCardBackground)
                .foregroundStyle(Theme.Colors.orange600)
                .clipShape(Capsule())
            }
            .accessibleButton(
                label: "Log out",
                hint: "Sign out of your account"
            )
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Account")
                .font(Theme.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Theme.Spacing.sm) {
                settingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Streak reminders & insights",
                    color: Theme.Colors.orange600
                ) {
                    // Navigate to notifications settings
                }

                settingsRow(
                    icon: "crown.fill",
                    title: "Manage Subscription",
                    subtitle: subscriptionViewModel.isPremium ? "Premium Active" : "Free Plan",
                    color: Color.yellow
                ) {
                    subscriptionViewModel.presentPaywall(for: "Manage Subscription")
                }

                settingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "FAQs and contact",
                    color: Theme.Colors.blue600
                ) {
                    // Navigate to help
                }

                Button {
                    showingLogoutConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(Theme.Colors.dangerRed)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Log Out")
                                .font(Theme.Typography.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.Colors.dangerRed)
                            Text("Sign out of your account")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
                }
                .buttonStyle(.plain)
                .accessibleButton(
                    label: "Log out",
                    hint: "Sign out of your account"
                )
            }
        }
    }

    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.Typography.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(Theme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private func dogProfileCard(_ profile: DogProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "pawprint.fill")
                    .foregroundStyle(Theme.Colors.blue600)
                Text(profile.name)
                    .font(Theme.Typography.title)
                Spacer()
            }

            Grid(alignment: .leading, horizontalSpacing: Theme.Spacing.lg, verticalSpacing: Theme.Spacing.sm) {
                GridRow {
                    gridItem(label: "Breed", value: profile.breed)
                    gridItem(label: "Age", value: "\(profile.age) yrs")
                }
                GridRow {
                    gridItem(label: "Weight", value: "\(profile.weight, default: "%.0f") lbs")
                    gridItem(label: "Risk", value: profile.riskLevel.displayText)
                }
            }
        }
        .cardStyle(
            backgroundColor: Theme.Colors.blueCardBackground,
            borderColor: Theme.Colors.blueCardBorder
        )
    }

    private func gridItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(Theme.Typography.subheadline.weight(.semibold))
        }
    }

    private var todaysCopperCard: some View {
        Group {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    Text("Today's Copper")
                        .font(Theme.Typography.headline)
                        .accessibilityIdentifier("todays_intake_label")
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: foodLogViewModel.copperStatus.iconName)
                        Text(foodLogViewModel.copperStatus.text)
                    }
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .foregroundStyle(foodLogViewModel.copperStatus.color)
                    .badgeStyle(
                        backgroundColor: foodLogViewModel.copperStatus.backgroundColor,
                        foregroundColor: foodLogViewModel.copperStatus.color
                    )
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", foodLogViewModel.totalCopperToday))
                        .font(Theme.Typography.customTitle(32))
                        .fontWeight(.bold)
                        .foregroundStyle(foodLogViewModel.copperStatus.color)
                    Text("/ \(dogProfile?.dailyCopperLimit ?? 5.0, specifier: "%.1f") mg")
                        .font(Theme.Typography.callout)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("recommended_limit_label")
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))

                        Capsule()
                            .fill(foodLogViewModel.copperStatus.color)
                            .frame(width: geometry.size.width * (foodLogViewModel.copperPercentage / 100))
                    }
                }
                .frame(height: 10)
            }
            .cardStyle(
                backgroundColor: foodLogViewModel.copperStatus.backgroundColor,
                borderColor: foodLogViewModel.copperStatus.borderColor
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("copper_tracker_card")
    }

    private var quickActionsCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Quick Actions")
                    .font(Theme.Typography.headline)
                Spacer()
            }

            HStack(spacing: Theme.Spacing.md) {
                quickActionButton(
                    icon: "barcode.viewfinder",
                    title: "Scan",
                    color: Theme.Colors.orange600
                ) {
                    if subscriptionViewModel.isPremium {
                        showingScanner = true
                    } else {
                        subscriptionViewModel.presentPaywall(for: "Barcode Scanner")
                    }
                }

                quickActionButton(
                    icon: "chart.bar.fill",
                    title: "Stats",
                    color: Theme.Colors.blue600
                ) {
                    selectedTab = .log
                }
            }
        }
        .cardStyle()
    }

    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.Typography.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.lg)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Theme.Colors.warningYellow)
                Text("Insights")
                    .font(Theme.Typography.headline)
                Spacer()
            }

            if foodLogViewModel.todaysEntries.isEmpty {
                Text("Start logging food to see personalized insights")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                insightRow(
                    icon: "fork.knife",
                    text: "You've logged \(foodLogViewModel.todaysEntries.count) food items today"
                )

                if foodLogViewModel.copperPercentage > 70 {
                    insightRow(
                        icon: "exclamationmark.triangle.fill",
                        text: "You're approaching your daily copper limit",
                        color: Theme.Colors.warningYellow
                    )
                }
            }
        }
        .cardStyle()
    }

    private func insightRow(icon: String, text: String, color: Color = .primary) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(Theme.Typography.subheadline)
            Spacer()
        }
    }

    // MARK: - Scanner Tab
    private var scannerTab: some View {
        PremiumGate(
            viewModel: subscriptionViewModel,
            featureName: "Barcode Scanner"
        ) {
            BarcodeScannerView(viewModel: scannerViewModel)
        }
    }

    // MARK: - Log Tab
    private var logTab: some View {
        FoodLogView(viewModel: foodLogViewModel)
    }
}

// MARK: - Dashboard Tab
enum DashboardTab {
    case home
    case scan
    case log
}

// MARK: - Previews
#Preview("Dashboard") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DogProfile.self, FoodEntry.self, configurations: config)
    let context = container.mainContext

    let profile = DogProfile.sampleProfile
    context.insert(profile)

    let subscriptionVM = SubscriptionViewModel(subscriptionService: SubscriptionServiceMock())
    let scannerVM = ScannerViewModel(openFoodFactsService: OpenFoodFactsServiceMock(), dogProfile: profile)
    let foodLogVM = FoodLogViewModel(modelContext: context, dogProfile: profile)

    return DashboardView(
        subscriptionViewModel: subscriptionVM,
        scannerViewModel: scannerVM,
        foodLogViewModel: foodLogVM,
        onLogout: {
            print("Logout tapped")
        }
    )
    .modelContainer(container)
}

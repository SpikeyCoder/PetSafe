import SwiftUI
import SwiftData

// MARK: - Settings View
/// Settings and account management screen
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    
    @Query private var profiles: [DogProfile]
    private var dogProfile: DogProfile? { profiles.first }
    
    var onLogout: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                if let profile = dogProfile {
                    Section {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "pawprint.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.Colors.blue600)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(Theme.Typography.headline)
                                Text("\(profile.breed) • \(profile.age) yrs")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, Theme.Spacing.sm)
                    }
                }
                
                // Subscription Section
                Section {
                    Button {
                        subscriptionViewModel.presentPaywall(for: "Manage Subscription")
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.yellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Subscription")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(.primary)
                                Text(subscriptionViewModel.isPremium ? "Premium Active" : "Free Plan")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Premium")
                }
                
                // App Settings Section
                Section {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label {
                            Text("Notifications")
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(Theme.Colors.orange600)
                        }
                    }
                    
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Label {
                            Text("Edit Profile")
                        } icon: {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Theme.Colors.blue600)
                        }
                    }
                } header: {
                    Text("Settings")
                }
                
                // Support Section
                Section {
                    NavigationLink {
                        HelpSupportView()
                    } label: {
                        Label {
                            Text("Help & Support")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(Theme.Colors.blue600)
                        }
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label {
                            Text("About")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                } header: {
                    Text("Support")
                }
                
                // Account Section
                Section {
                    Button(role: .destructive) {
                        dismiss()
                        onLogout()
                    } label: {
                        HStack {
                            Label {
                                Text("Log Out")
                            } icon: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .accessibilityLabel("Close")
                    .accessibilityIdentifier("close_button")
                }
            }
        }
    }
}

// MARK: - Placeholder Views
// These are placeholder views that can be expanded later

struct NotificationSettingsView: View {
    @State private var dailyReminders = true
    @State private var copperAlerts = true
    @State private var weeklyInsights = true
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $dailyReminders) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Reminders")
                            .font(Theme.Typography.subheadline)
                        Text("Get reminded to log your dog's food")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Toggle(isOn: $copperAlerts) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Copper Alerts")
                            .font(Theme.Typography.subheadline)
                        Text("Alert when approaching daily limit")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Toggle(isOn: $weeklyInsights) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Insights")
                            .font(Theme.Typography.subheadline)
                        Text("Summary of your week's copper tracking")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Enable notifications to stay on top of your dog's copper intake")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileEditView: View {
    @Query private var profiles: [DogProfile]
    private var dogProfile: DogProfile? { profiles.first }
    
    var body: some View {
        List {
            Section {
                if let profile = dogProfile {
                    LabeledContent("Name", value: profile.name)
                    LabeledContent("Breed", value: profile.breed)
                    LabeledContent("Age", value: "\(profile.age) years")
                    LabeledContent("Weight", value: String(format: "%.1f lbs", profile.weight))
                }
            } header: {
                Text("Profile Information")
            } footer: {
                Text("Profile editing coming soon")
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpSupportView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Frequently Asked Questions") {
                    Text("FAQs coming soon")
                }
                
                NavigationLink("Contact Support") {
                    Text("Contact form coming soon")
                }
                
                Link("Visit Our Website", destination: URL(string: "https://petsafe.example.com")!)
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "100")
            } header: {
                Text("App Information")
            }
            
            Section {
                NavigationLink("Privacy Policy") {
                    Text("Privacy policy coming soon")
                }
                
                NavigationLink("Terms of Service") {
                    Text("Terms coming soon")
                }
                
                NavigationLink("Licenses") {
                    Text("Open source licenses coming soon")
                }
            } header: {
                Text("Legal")
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DogProfile.self, FoodEntry.self, configurations: config)
    let context = container.mainContext
    
    let profile = DogProfile.sampleProfile
    context.insert(profile)
    
    let subscriptionVM = SubscriptionViewModel(subscriptionService: SubscriptionServiceMock())
    
    return SettingsView(
        subscriptionViewModel: subscriptionVM,
        onLogout: {
            print("Logout tapped")
        }
    )
    .modelContainer(container)
}

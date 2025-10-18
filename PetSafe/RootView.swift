import SwiftUI

struct RootView: View {
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
            } else {
                MembershipPlans(
                    onPurchase: { plan, method in
                        print("Purchased plan: \(plan), payment method: \(String(describing: method))")
                    },
                    onSkip: {
                        print("User skipped membership.")
                    },
                    userProvider: "apple"
                )
                .transition(.opacity)
            }
        }
        .task {
            // Simulate initial load
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.35)) {
                isLoading = false
            }
        }
    }
}

#Preview {
    RootView()
}

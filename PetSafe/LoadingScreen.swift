import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Emblem
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.orange)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                        .frame(width: 88, height: 88)

                    Image(systemName: "checkmark.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 4)

                // Title
                Text("PetSafe")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(.label))

                // Subtitle
                Text("Protecting your pet's health")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Spinner
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.orange)
                    .padding(.top, 12)
            }
            .padding()
        }
    }
}

#Preview {
    LoadingScreen()
}

import SwiftUI
import AVFoundation

// MARK: - Barcode Scanner View
/// Camera-based barcode scanner with live preview and result display
struct BarcodeScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Camera preview layer
            CameraPreview(viewModel: viewModel)
                .ignoresSafeArea()

            // Overlay UI
            VStack {
                // Top bar
                topBar

                Spacer()

                // Scanning indicator or result
                if viewModel.scanState.isScanning {
                    scanningIndicator
                } else if case .processing = viewModel.scanState {
                    processingIndicator
                } else if case .found(let product) = viewModel.scanState {
                    ProductResultView(
                        product: product,
                        onAddToLog: { amount in
                            // Will be implemented in Phase 4
                            print("Add to log: \(amount)g")
                            viewModel.resetScan()
                        },
                        onRescan: {
                            viewModel.resetScan()
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Instructions
                if viewModel.scanState.isScanning {
                    instructions
                }
            }

            // Error overlay
            if case .error(let message) = viewModel.scanState {
                errorOverlay(message: message)
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.requestCameraPermission()

            if viewModel.cameraPermissionStatus == .authorized {
                do {
                    _ = try viewModel.setupCamera()
                    viewModel.startScanning()
                } catch {
                    print("Camera setup failed: \(error)")
                }
            }
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                viewModel.stopScanning()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(Theme.Spacing.md)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Spacer()

            Text("Scan Barcode")
                .font(Theme.Typography.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding()
    }

    // MARK: - Scanning Indicator
    private var scanningIndicator: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Scanning frame
            ScanningFrame()
                .frame(width: 280, height: 280)

            Text("Position barcode in frame")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
        }
    }

    // MARK: - Processing Indicator
    private var processingIndicator: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Looking up product...")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.white)
        }
        .padding(Theme.Spacing.xxl)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    // MARK: - Instructions
    private var instructions: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 32))
                .foregroundStyle(.white)

            Text("Align barcode within the frame")
                .font(Theme.Typography.caption)
                .foregroundStyle(.white)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // MARK: - Error Overlay
    private func errorOverlay(message: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.dangerRed)

            Text("Error")
                .font(Theme.Typography.title)

            Text(message)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                viewModel.clearError()
                viewModel.resetScan()
            } label: {
                Text("Try Again")
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.orange600)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var viewModel: ScannerViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing preview layer if any
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Add camera preview if available
        if let session = try? viewModel.setupCamera() {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = uiView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            uiView.layer.addSublayer(previewLayer)

            // Auto-layout
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

// MARK: - Scanning Frame Animation
struct ScanningFrame: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Corner brackets
            VStack {
                HStack {
                    cornerBracket(.topLeft)
                    Spacer()
                    cornerBracket(.topRight)
                }
                Spacer()
                HStack {
                    cornerBracket(.bottomLeft)
                    Spacer()
                    cornerBracket(.bottomRight)
                }
            }

            // Scanning line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Theme.Colors.orange600.opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .offset(y: isAnimating ? 130 : -130)
                .animation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }

    private func cornerBracket(_ position: CornerPosition) -> some View {
        ZStack {
            switch position {
            case .topLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().frame(width: 40, height: 3)
                    Rectangle().frame(width: 3, height: 40)
                }
            case .topRight:
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle().frame(width: 40, height: 3)
                    HStack {
                        Spacer()
                        Rectangle().frame(width: 3, height: 40)
                    }
                }
            case .bottomLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().frame(width: 3, height: 40)
                    Rectangle().frame(width: 40, height: 3)
                }
            case .bottomRight:
                VStack(alignment: .trailing, spacing: 0) {
                    HStack {
                        Spacer()
                        Rectangle().frame(width: 3, height: 40)
                    }
                    Rectangle().frame(width: 40, height: 3)
                }
            }
        }
        .foregroundStyle(.white)
    }

    enum CornerPosition {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}

// MARK: - Camera Permission View
struct CameraPermissionView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Image(systemName: "camera.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.orange600)

            Text("Camera Access Required")
                .font(Theme.Typography.title)

            Text("PetSafe needs camera access to scan barcodes. Please enable it in Settings.")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(Theme.Typography.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.orange600)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Previews
#Preview("Scanner View") {
    NavigationStack {
        BarcodeScannerView(viewModel: .preview)
    }
}

#Preview("Permission Denied") {
    CameraPermissionView()
}

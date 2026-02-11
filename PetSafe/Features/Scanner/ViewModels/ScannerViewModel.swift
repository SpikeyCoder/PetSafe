import Foundation
internal import Combine
import SwiftUI
@preconcurrency import AVFoundation

// MARK: - Scanner ViewModel
/// Manages barcode scanning and product lookup
@MainActor
final class ScannerViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var scanState: ScanState = .idle
    @Published var scannedProduct: ScannedProduct?
    @Published var errorMessage: String?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined

    // MARK: - Dependencies
    private let openFoodFactsService: OpenFoodFactsService
    private let dogProfile: DogProfile?

    // MARK: - Camera Properties
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var lastScannedCode: String?
    private var lastScanTime: Date?

    // Prevent duplicate scans within 2 seconds
    private let scanCooldownSeconds: TimeInterval = 2.0

    // MARK: - Initialization
    init(
        openFoodFactsService: OpenFoodFactsService,
        dogProfile: DogProfile? = nil
    ) {
        self.openFoodFactsService = openFoodFactsService
        self.dogProfile = dogProfile
        super.init()
    }

    // MARK: - Camera Permission
    func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionStatus = status

        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraPermissionStatus = granted ? .authorized : .denied
        case .authorized:
            cameraPermissionStatus = .authorized
        case .denied, .restricted:
            cameraPermissionStatus = status
        @unknown default:
            cameraPermissionStatus = .denied
        }
    }

    // MARK: - Camera Setup
    func setupCamera() throws -> AVCaptureSession {
        guard cameraPermissionStatus == .authorized else {
            throw ScannerError.cameraPermissionDenied
        }

        let session = AVCaptureSession()
        session.beginConfiguration()

        // Input: Camera device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            throw ScannerError.noCameraAvailable
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            throw ScannerError.cameraSetupFailed(error)
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            throw ScannerError.cameraSetupFailed(nil)
        }

        // Output: Metadata for barcode detection
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .upce,
                .code128,
                .code39,
                .qr
            ]
        } else {
            throw ScannerError.cameraSetupFailed(nil)
        }

        session.commitConfiguration()
        captureSession = session

        return session
    }

    func startScanning() {
        guard let session = captureSession else { return }
        guard !session.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        scanState = .scanning
    }

    func stopScanning() {
        guard let session = captureSession else { return }
        guard session.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
        }

        scanState = .idle
    }

    // MARK: - Product Lookup
    func lookupProduct(barcode: String) async {
        // Debounce: Prevent duplicate scans
        if let lastCode = lastScannedCode,
           let lastTime = lastScanTime,
           lastCode == barcode,
           Date().timeIntervalSince(lastTime) < scanCooldownSeconds {
            return
        }

        lastScannedCode = barcode
        lastScanTime = Date()

        scanState = .processing(barcode)

        do {
            let offProduct = try await openFoodFactsService.fetchProduct(barcode: barcode)

            // Analyze copper content and safety
            let analysis = analyzeCopperSafety(product: offProduct)

            let scannedProduct = ScannedProduct(
                barcode: barcode,
                name: offProduct.name,
                brand: offProduct.displayBrand,
                copperMgPer100g: offProduct.copperMgPer100g ?? analysis.estimatedCopper,
                safetyLevel: analysis.safetyLevel,
                badges: offProduct.badges,
                ingredients: offProduct.ingredients,
                imageUrl: offProduct.imageUrl,
                isEstimated: offProduct.copperMgPer100g == nil
            )

            self.scannedProduct = scannedProduct
            scanState = .found(scannedProduct)

        } catch {
            errorMessage = "Could not find product information. Please try again."
            scanState = .error(error.localizedDescription)
        }
    }

    func resetScan() {
        scannedProduct = nil
        errorMessage = nil
        lastScannedCode = nil
        lastScanTime = nil
        scanState = .scanning
    }

    func clearError() {
        errorMessage = nil
        scanState = .idle
    }

    // MARK: - Copper Analysis
    private func analyzeCopperSafety(product: OFFProduct) -> CopperAnalysis {
        // If we have actual copper data, use it
        if let copper = product.copperMgPer100g {
            let safety: FoodSafetyLevel
            if copper < 1.0 {
                safety = .safe
            } else if copper < 2.5 {
                safety = .caution
            } else {
                safety = .danger
            }
            return CopperAnalysis(estimatedCopper: copper, safetyLevel: safety)
        }

        // Otherwise, estimate based on ingredients
        let ingredients = product.ingredients.map { $0.lowercased() }
        var estimatedCopper: Double = 0.5 // default moderate

        // High-risk ingredients
        if ingredients.contains(where: { $0.contains("liver") || $0.contains("organ") }) {
            estimatedCopper = 4.0
        } else if ingredients.contains(where: { $0.contains("shellfish") || $0.contains("oyster") }) {
            estimatedCopper = 6.0
        } else if ingredients.contains(where: { $0.contains("beef") || $0.contains("lamb") }) {
            estimatedCopper = 1.2
        } else if ingredients.contains(where: { $0.contains("chicken") || $0.contains("poultry") }) {
            estimatedCopper = 0.4
        } else if ingredients.contains(where: { $0.contains("fish") || $0.contains("salmon") }) {
            estimatedCopper = 0.7
        } else if ingredients.contains(where: { $0.contains("grain") || $0.contains("rice") }) {
            estimatedCopper = 0.2
        }

        let safety: FoodSafetyLevel
        if estimatedCopper < 1.0 {
            safety = .safe
        } else if estimatedCopper < 2.5 {
            safety = .caution
        } else {
            safety = .danger
        }

        return CopperAnalysis(estimatedCopper: estimatedCopper, safetyLevel: safety)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = metadataObject.stringValue else {
            return
        }

        // Play haptic feedback
        Task { @MainActor in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            await lookupProduct(barcode: barcode)
        }
    }
}

// MARK: - Scan State
enum ScanState: Equatable {
    case idle
    case scanning
    case processing(String) // barcode being processed
    case found(ScannedProduct)
    case error(String)

    var isScanning: Bool {
        self == .scanning
    }

    var isProcessing: Bool {
        if case .processing = self { return true }
        return false
    }
}

// MARK: - Scanned Product Model
struct ScannedProduct: Identifiable, Equatable {
    let id = UUID()
    let barcode: String
    let name: String
    let brand: String
    let copperMgPer100g: Double
    let safetyLevel: FoodSafetyLevel
    let badges: [String]
    let ingredients: [String]
    let imageUrl: String?
    let isEstimated: Bool // true if copper content is estimated, not actual data

    var safetyColor: Color {
        switch safetyLevel {
        case .safe: return Theme.Colors.safeGreen
        case .caution: return Theme.Colors.warningYellow
        case .danger: return Theme.Colors.dangerRed
        }
    }

    var safetyText: String {
        safetyLevel.displayText
    }

    var safetyIcon: String {
        safetyLevel.iconName
    }

    var copperLevelDescription: String {
        if copperMgPer100g < 0.5 {
            return "Very Low"
        } else if copperMgPer100g < 1.0 {
            return "Low"
        } else if copperMgPer100g < 2.0 {
            return "Moderate"
        } else if copperMgPer100g < 3.0 {
            return "High"
        } else {
            return "Very High"
        }
    }
}

// MARK: - Copper Analysis Result
private struct CopperAnalysis {
    let estimatedCopper: Double
    let safetyLevel: FoodSafetyLevel
}

// MARK: - Scanner Errors
enum ScannerError: LocalizedError {
    case cameraPermissionDenied
    case noCameraAvailable
    case cameraSetupFailed(Error?)
    case productNotFound
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required to scan barcodes. Please enable it in Settings."
        case .noCameraAvailable:
            return "No camera is available on this device."
        case .cameraSetupFailed(let error):
            return "Failed to setup camera: \(error?.localizedDescription ?? "Unknown error")"
        case .productNotFound:
            return "Product not found in database. Try entering manually."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview Helper
extension ScannerViewModel {
    static var preview: ScannerViewModel {
        ScannerViewModel(
            openFoodFactsService: OpenFoodFactsServiceMock(),
            dogProfile: .sampleProfile
        )
    }
}

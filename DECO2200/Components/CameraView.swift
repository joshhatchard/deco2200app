import SwiftUI
import Combine
import AVFoundation

#if canImport(UIKit)
import UIKit
import ImageIO

/// Drives a live back-camera capture session and hands back JPEG/HEIC data for
/// each shot. All AVFoundation work happens on a private serial queue; the one
/// published flag is updated on the main actor.
final class CameraController: ObservableObject {
    let session = AVCaptureSession()
    @Published var isAuthorized = false
    @Published var zoomFactor: CGFloat = 1

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "scrapmap.camera.session")
    private let captureDelegate = PhotoCaptureDelegate()
    private var isConfigured = false
    private var position: AVCaptureDevice.Position = .back
    private var videoInput: AVCaptureDeviceInput?

    /// Ask for permission (once), configure the session if needed, and start
    /// the preview running off the main thread.
    func start() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run { self.isAuthorized = granted }
        guard granted else { return }
        sessionQueue.async {
            if !self.isConfigured { self.configureSession() }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    /// Switch between the back and front cameras.
    func flip() {
        sessionQueue.async {
            self.position = (self.position == .back) ? .front : .back
            self.session.beginConfiguration()
            self.addVideoInput(for: self.position)
            self.session.commitConfiguration()
            self.lockAndZoom(1) // reset zoom when switching cameras
        }
    }

    /// Pinch-to-zoom entry point — clamps to the device's supported range.
    func setZoom(_ factor: CGFloat) {
        sessionQueue.async { self.lockAndZoom(factor) }
    }

    /// Applies a zoom factor to the active device. Must be called on the
    /// session queue.
    private func lockAndZoom(_ factor: CGFloat) {
        guard let device = videoInput?.device else { return }
        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 8)
        let clamped = max(1, min(factor, maxZoom))
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
            DispatchQueue.main.async { self.zoomFactor = clamped }
        } catch {}
    }

    /// Take a single photo. Returns the encoded image data, or nil if the
    /// camera isn't ready (e.g. permission denied or running in the Simulator).
    func capturePhoto() async -> Data? {
        guard isAuthorized, isConfigured else { return nil }
        return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            sessionQueue.async {
                // No active video connection (e.g. Simulator, or permission
                // denied) — return immediately instead of waiting forever for a
                // delegate callback that will never come.
                guard self.photoOutput.connection(with: .video)?.isActive == true else {
                    continuation.resume(returning: nil)
                    return
                }
                self.captureDelegate.onCapture = { data in
                    // Downsample immediately so the app only ever stores/decodes
                    // a modest image, not a multi-megapixel camera frame.
                    let processed = data.flatMap { CameraController.downsample($0, maxPixel: 1280) } ?? data
                    continuation.resume(returning: processed)
                }
                self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self.captureDelegate)
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        addVideoInput(for: position)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
        isConfigured = true
    }

    /// Efficiently shrink a captured photo to at most `maxPixel` on its long
    /// edge using ImageIO, so we never hold or repeatedly decode full-res data.
    static func downsample(_ data: Data, maxPixel: CGFloat) -> Data? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.9)
    }

    /// Swap the active camera input for the given position, removing any
    /// existing one first. Must be called inside a session configuration block.
    private func addVideoInput(for position: AVCaptureDevice.Position) {
        if let existing = videoInput {
            session.removeInput(existing)
            videoInput = nil
        }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)
        videoInput = input
    }
}

/// Bridges the one-shot photo delegate callback back to the async caller.
/// AVFoundation invokes this off the main thread, so the conformance is
/// explicitly nonisolated.
private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    nonisolated(unsafe) var onCapture: ((Data?) -> Void)?

    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = error == nil ? photo.fileDataRepresentation() : nil
        let callback = onCapture
        onCapture = nil
        callback?(data)
    }
}

/// SwiftUI wrapper around an `AVCaptureVideoPreviewLayer`-backed view.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

/// Decodes photo data once and reuses the `UIImage`, so scrolling/dragging
/// views don't re-decode the same bytes on every frame.
enum ImageCache {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(key: String, data: Data) -> UIImage? {
        let nsKey = key as NSString
        if let cached = cache.object(forKey: nsKey) { return cached }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: nsKey)
        return image
    }
}
#endif

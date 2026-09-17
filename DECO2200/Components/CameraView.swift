import SwiftUI
import Combine
import AVFoundation

#if canImport(UIKit)
import UIKit
import ImageIO

/// Drives a live back-camera capture session and hands back JPEG/HEIC data for
/// each shot. All AVFoundation work happens on a private serial queue; only the
/// small published flags are touched on the main actor.
@MainActor
final class CameraController: ObservableObject {
    let session = AVCaptureSession()
    @Published var isAuthorized = false

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "scrapmap.camera.session")
    private let captureDelegate = PhotoCaptureDelegate()
    private var isConfigured = false
    private var position: AVCaptureDevice.Position = .back
    private var videoInput: AVCaptureDeviceInput?

    /// Ask for permission (once), configure the session if needed, and start
    /// the preview running off the main thread.
    func start() async {
        if !isAuthorized {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        guard isAuthorized else { return }
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
        }
    }

    /// Take a single photo. Returns the encoded image data, or nil if the
    /// camera isn't ready (e.g. permission denied or running in the Simulator).
    func capturePhoto() async -> Data? {
        guard isAuthorized, isConfigured else { return nil }
        return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            sessionQueue.async {
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
private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var onCapture: ((Data?) -> Void)?

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
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

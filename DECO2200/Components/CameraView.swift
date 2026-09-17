import SwiftUI
import Combine
import AVFoundation

#if canImport(UIKit)
import UIKit

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

    /// Take a single photo. Returns the encoded image data, or nil if the
    /// camera isn't ready (e.g. permission denied or running in the Simulator).
    func capturePhoto() async -> Data? {
        guard isAuthorized, isConfigured else { return nil }
        return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            sessionQueue.async {
                self.captureDelegate.onCapture = { data in
                    continuation.resume(returning: data)
                }
                self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self.captureDelegate)
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
        isConfigured = true
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
#endif

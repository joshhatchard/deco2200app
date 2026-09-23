import SwiftUI
import Combine
import AVFoundation

/// Records a short voice memo to a temp file and hands back the encoded audio.
/// AVAudioSession/permission calls are iOS-only; other platforms no-op.
final class VoiceMemoRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var startedAt: Date?

    private var recorder: AVAudioRecorder?
    private var fileURL: URL?

    func start() {
        #if os(iOS)
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self, granted else { return }
                self.beginRecording()
            }
        }
        #endif
    }

    private func beginRecording() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch { return }
        #endif
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("scrapmap-memo-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.record()
            recorder = rec
            fileURL = url
            isRecording = true
            startedAt = Date()
        } catch {}
    }

    /// Stops recording and returns the encoded audio data (or nil).
    func stop() -> Data? {
        recorder?.stop()
        isRecording = false
        startedAt = nil
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
        let data = fileURL.flatMap { try? Data(contentsOf: $0) }
        recorder = nil
        return data
    }
}

/// Plays voice-memo data. Delegate conformance is nonisolated since AVFoundation
/// may call back off the main thread.
final class VoiceMemoPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate, @unchecked Sendable {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?

    func toggle(data: Data) {
        if isPlaying { stop(); return }
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        do {
            let p = try AVAudioPlayer(data: data)
            p.delegate = self
            p.play()
            player = p
            isPlaying = true
        } catch {}
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.isPlaying = false }
    }
}

/// Reusable voice-message pill: play/stop circle, waveform, and duration.
struct VoiceMemoPlayButton: View {
    let data: Data
    /// Hides the waveform for tight spaces (e.g. the small profile tile).
    var compact: Bool = false

    @StateObject private var player = VoiceMemoPlayer()
    @State private var durationText = "0:00"

    private let bars: [CGFloat] = [10, 16, 24, 13, 21, 29, 15, 25, 11, 27, 18, 23, 14, 20, 12]

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().strokeBorder(Palette.lilac, lineWidth: 3)
                    .frame(width: 38, height: 38)
                Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Palette.lilac)
                    .offset(x: player.isPlaying ? 0 : 1)
            }

            if compact {
                Spacer(minLength: 4)
            } else {
                HStack(spacing: 3) {
                    ForEach(bars.indices, id: \.self) { i in
                        Capsule().fill(Palette.lilac.opacity(0.55))
                            .frame(width: 3, height: bars[i])
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
            }

            Text(durationText)
                .font(.mono(14, weight: .medium))
                .foregroundStyle(Palette.ink)
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Capsule().fill(.white))
        .hardShadow(Palette.ink.opacity(0.06), x: 2, y: 3)
        .contentShape(Capsule())
        .onTapGesture { player.toggle(data: data) }
        .onAppear { computeDuration() }
        .onDisappear { player.stop() }
    }

    private func computeDuration() {
        guard let probe = try? AVAudioPlayer(data: data) else { return }
        let secs = Int(probe.duration.rounded())
        durationText = String(format: "%d:%02d", secs / 60, secs % 60)
    }
}

#Preview("Voice memo pill") {
    VoiceMemoPlayButton(data: Data())
        .padding()
        .frame(width: 340)
        .background(Palette.mint)
}

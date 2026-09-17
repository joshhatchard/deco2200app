import SwiftUI

/// The blob mascot's face — reused at every size across the app, from the
/// 300pt nudge hero down to a 40pt "peek" on the share screen. Ears and
/// the smile are optional because smaller/incidental uses (profile
/// avatar, audience picker) only show eyes.
struct BlobFace: View {
    var size: CGFloat
    var color: Color
    var showEars: Bool = false
    var showSmile: Bool = false
    var eyeColor: Color = Palette.ink
    var blink: Bool = true
    var bob: Bool = false
    var wobble: Bool = false

    @State private var blinking = false
    @State private var bobbing = false

    private var eyeSize: CGSize {
        CGSize(width: size * 0.083, height: size * 0.177)
    }
    private var eyeGap: CGFloat { size * 0.135 }

    var body: some View {
        ZStack {
            if showEars {
                ear.rotationEffect(.degrees(-15)).offset(x: -size * 0.26, y: -size * 0.42)
                ear.rotationEffect(.degrees(15)).offset(x: size * 0.26, y: -size * 0.42)
            }
            BlobShape()
                .fill(color)
                .frame(width: size, height: size)

            HStack(spacing: eyeGap) {
                eye
                eye
            }
            .offset(y: -size * 0.08)

            if showSmile {
                SmileShape()
                    .stroke(eyeColor, style: StrokeStyle(lineWidth: size * 0.038, lineCap: .round))
                    .frame(width: size * 0.36, height: size * 0.18)
                    .offset(y: size * 0.06)
            }
        }
        .frame(width: size, height: size)
        .offset(y: bob && bobbing ? -size * 0.03 : 0)
        .rotationEffect(.degrees(wobble && bobbing ? 2 : (wobble ? -2 : 0)))
        .onAppear {
            if blink {
                withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true).delay(1.4)) {
                    blinking.toggle()
                }
            }
            if bob || wobble {
                withAnimation(.easeInOut(duration: bob ? 1.8 : 0.8).repeatForever(autoreverses: true)) {
                    bobbing = true
                }
            }
        }
    }

    private var ear: some View {
        Capsule()
            .fill(color)
            .frame(width: size * 0.13, height: size * 0.28)
    }

    private var eye: some View {
        Capsule()
            .fill(eyeColor)
            .frame(width: eyeSize.width, height: eyeSize.height)
            .scaleEffect(y: blinking ? 0.12 : 1, anchor: .center)
    }
}

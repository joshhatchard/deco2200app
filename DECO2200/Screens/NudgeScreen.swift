import SwiftUI

/// Full-bleed ambient nudge — no interruption, no urgency chrome, just the
/// mascot and a plain invitation.
struct NudgeScreen: View {
    @ObservedObject var state: AppState

    private let goldInk = Color(hex: 0x6B5A17)

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                MonoLabel(text: "Sitting 1h 52m", size: 10, color: goldInk, tracking: 1.8)
                Text("Go find something.")
                    .font(.display(52))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Text("Today everyone's hunting \u{201C}\(Hunts.daily.title)\u{201D}. Shoot as many as you like.")
                    .font(.body(15.5, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: 280, alignment: .leading)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 26)
            .padding(.top, 60)
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                floatingShape(RoundedRectangle(cornerRadius: 5), Palette.green, size: 20, rotation: 22)
                    .position(x: 40, y: 90)
                floatingShape(Circle(), Palette.sky, size: 26, rotation: 0)
                    .position(x: 330, y: 60)
                floatingShape(RoundedRectangle(cornerRadius: 4), Palette.lilac, size: 14, rotation: -18)
                    .position(x: 295, y: 180)

                BlobFace(size: 300, color: Palette.coral, showEars: true, showSmile: true, bob: true)
                    .padding(.bottom, 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 8) {
                Button {
                    state.go(.theme)
                } label: {
                    Text("Let's go outside")
                        .font(.display(22, weight: .bold))
                        .foregroundStyle(Palette.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(Capsule().fill(Palette.ink))
                        .shadow(color: Palette.ink.opacity(0.08), radius: 0, x: 0, y: 3)
                }
                .buttonStyle(.plain)

                Button {
                    state.go(.home)
                } label: {
                    MonoLabel(text: "Snooze 10 min", size: 11, color: goldInk, tracking: 1.4)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.butter)
    }

    private func floatingShape<S: Shape>(_ shape: S, _ color: Color, size: CGFloat, rotation: Double) -> some View {
        shape.fill(color).frame(width: size, height: size).rotationEffect(.degrees(rotation))
    }
}

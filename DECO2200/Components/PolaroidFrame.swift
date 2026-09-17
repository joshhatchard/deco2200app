import SwiftUI

/// The "photo with a pushpin" card used for feed posts and scrapbook
/// tiles: a white sticker card, a hard offset shadow, and a coloured pin
/// perched on top. Home's feed cards sit dead straight (tilt 0) per a
/// later revision; the profile scrapbook keeps its alternating tilt.
struct PolaroidFrame<Content: View>: View {
    var pinColor: Color
    var tilt: Double = 0
    var pinSize: CGFloat = 18
    var cornerRadius: CGFloat = 8
    var padding: CGFloat = 12
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(.white))
            .overlay(alignment: .top) {
                Circle()
                    .fill(pinColor)
                    .frame(width: pinSize, height: pinSize)
                    .shadow(color: Palette.ink.opacity(0.08), radius: 0, x: 0, y: 2)
                    .offset(y: -pinSize / 2)
            }
            .hardShadow(Palette.ink.opacity(0.05), x: 4, y: 4)
            .rotationEffect(.degrees(tilt))
    }
}

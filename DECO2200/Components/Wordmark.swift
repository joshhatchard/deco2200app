import SwiftUI

/// The "scrapmap" logotype — no mark was ever provided for this product,
/// so each letter of the wordmark itself is set at a small fixed rotation
/// to read as a hand-set sticker logo. Only shown on the Home screen.
struct Wordmark: View {
    var size: CGFloat = 30

    private let letters = Array("scrapmap")
    private let rotations: [Double] = [-8, 5, -4, 7, -6, 4, -7, 6]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(letters.indices, id: \.self) { i in
                Text(String(letters[i]))
                    .rotationEffect(.degrees(rotations[i]))
            }
        }
        .font(.display(size))
        .foregroundStyle(Palette.coral)
    }
}

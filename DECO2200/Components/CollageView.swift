import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Proportional flex-row collage: photos split into rows sized by how many
/// they hold, so the frame is always exactly filled at any photo count —
/// 1, 5, 17, 40. Re-keying the view by `seed` at the call site is what
/// makes "shake" feel like a genuine re-composition rather than a recolour.
struct CollageView: View {
    var count: Int
    var seed: Int
    var hue: Color
    var gap: CGFloat = 4
    var cornerRadius: CGFloat = 5
    /// Staggers each tile in with the prototype's `pf-land` pop, used right
    /// after a shake lands a new arrangement.
    var animateIn: Bool = false
    /// Real captured photos aligned to the flattened tile index. Empty for the
    /// abstract/other-user collages, which stay as tinted tiles.
    var photos: [Data?] = []

    private var rows: [CollageRow] { collageRows(count: count, seed: seed) }

    var body: some View {
        GeometryReader { geo in
            let gapTotal = CGFloat(max(0, rows.count - 1)) * gap
            let available = max(0, geo.size.height - gapTotal)
            VStack(spacing: gap) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(spacing: gap) {
                        ForEach(Array(row.indices.enumerated()), id: \.offset) { colIndex, photoIndex in
                            Tile(
                                color: Palette.tileColor(hue: hue, seed: seed + photoIndex),
                                imageData: photoIndex < photos.count ? photos[photoIndex] : nil,
                                cornerRadius: cornerRadius,
                                animateIn: animateIn,
                                delay: 0.05 * Double(rowIndex * 2 + colIndex)
                            )
                        }
                    }
                    .frame(height: available * row.grow)
                }
            }
        }
    }

    private struct Tile: View {
        var color: Color
        var imageData: Data?
        var cornerRadius: CGFloat
        var animateIn: Bool
        var delay: Double

        @State private var shown = false

        var body: some View {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
                .overlay {
                    #if canImport(UIKit)
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                    #endif
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(shown || !animateIn ? 1 : 0.55)
                .rotationEffect(.degrees(shown || !animateIn ? 0 : -8))
                .opacity(shown || !animateIn ? 1 : 0)
                .onAppear {
                    guard animateIn else { return }
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.72).delay(delay)) {
                        shown = true
                    }
                }
        }
    }
}

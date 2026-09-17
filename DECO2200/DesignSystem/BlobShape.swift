import SwiftUI

/// The mascot / theme-picker blob shape — CSS used an asymmetric
/// `border-radius: 52% 48% 44% 56% / 58% 56% 44% 42%` to get a squircle
/// that reads as "almost a circle, but alive". `UnevenRoundedRectangle`
/// gives the same four-corner asymmetry natively.
struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height)
        return UnevenRoundedRectangle(
            topLeadingRadius: r * 0.55,
            bottomLeadingRadius: r * 0.46,
            bottomTrailingRadius: r * 0.51,
            topTrailingRadius: r * 0.49,
            style: .continuous
        ).path(in: rect)
    }
}

/// A downward smile: the CSS trick was a bottom-only border on a rounded
/// box. Here it's an explicit arc so it reads correctly at any size.
struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY),
            radius: rect.width / 2,
            startAngle: .degrees(20),
            endAngle: .degrees(160),
            clockwise: false
        )
        return p
    }
}

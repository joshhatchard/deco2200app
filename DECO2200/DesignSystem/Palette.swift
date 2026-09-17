import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Colour tokens ported from `ScrapMap Playful.dc.html`.
/// Ink and cream are the two fixed text/surface anchors; HUES are the
/// per-theme accent colours the whole break "wears" once picked.
enum Palette {
    static let ink = Color(hex: 0x17201C)
    static let cream = Color(hex: 0xFFF7F0)

    static let butter = Color(hex: 0xFFD84D)
    static let coral = Color(hex: 0xFF5A4E)
    static let sky = Color(hex: 0x4EA8FF)
    static let lilac = Color(hex: 0xB57BFF)
    static let green = Color(hex: 0x00D274) // primary action colour

    /// Every green in the app resolves to the hunt-hero green.
    static let mint = green

    // Screen backgrounds
    static let homeBg = Color(hex: 0xE9F5EE)
    static let themeBg = Color(hex: 0xF1EAFF)
    static let galleryBg = sky
    static let shareBg = Color(hex: 0xFFEDE9)
    static let profileBg = Color(hex: 0xF1EAFF)
    static let appBg = Color(hex: 0xDDEEE3)

    static let mutedInk = Color(hex: 0x5B6B62)

    /// Percentages used to seed a family of tints from one hue (mirrors the
    /// `MIX` array used for every photo tile in the prototype).
    static let tileMix: [Double] = [100, 72, 50, 88, 36, 62, 96, 44, 78]

    static func tileColor(hue: Color, seed: Int) -> Color {
        let pct = tileMix[((seed % tileMix.count) + tileMix.count) % tileMix.count]
        return hue.mixed(with: cream, percent: pct)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    /// Approximates CSS `color-mix(in oklab, self P%, other)` by blending in
    /// linear RGB, which stays close to OKLab for the pastel/mid-saturation
    /// hues this palette uses and avoids a full OKLab round trip.
    func mixed(with other: Color, percent: Double) -> Color {
        let p = max(0, min(100, percent)) / 100
        let a = self.linearComponents
        let b = other.linearComponents
        func lerp(_ x: Double, _ y: Double) -> Double { x * p + y * (1 - p) }
        let r = lerp(a.r, b.r), g = lerp(a.g, b.g), bl = lerp(a.b, b.b)
        return Color(.sRGB,
                      red: Self.toSRGB(r), green: Self.toSRGB(g), blue: Self.toSRGB(bl),
                      opacity: a.a * p + b.a * (1 - p))
    }

    private var linearComponents: (r: Double, g: Double, b: Double, a: Double) {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Self.toLinear(Double(r)), Self.toLinear(Double(g)), Self.toLinear(Double(b)), Double(a))
        #else
        return (0, 0, 0, 1)
        #endif
    }

    private static func toLinear(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    private static func toSRGB(_ c: Double) -> Double {
        let clamped = max(0, min(1, c))
        return clamped <= 0.0031308 ? clamped * 12.92 : 1.055 * pow(clamped, 1 / 2.4) - 0.055
    }
}

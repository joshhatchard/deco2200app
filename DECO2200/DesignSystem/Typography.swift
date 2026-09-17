import SwiftUI

/// The prototype uses three Google-hosted fonts (Baloo 2 chunky display,
/// DM Mono for every label/number, Nunito for body/buttons). None of those
/// files are bundled with this handoff, so these helpers substitute the
/// closest system faces rather than shipping unlicensed font binaries:
/// heavy SF Rounded for display, monospaced-digit SF for DM Mono, and
/// rounded-design SF for Nunito body text. Swap in the real fonts by
/// replacing these three functions once the .ttf files are added to the
/// package and registered in Info.plist.
extension Font {
    /// Stand-in for "Baloo 2" — big, chunky, rounded headlines and numbers.
    static func display(_ size: CGFloat, weight: Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// Stand-in for "DM Mono" — uppercase tracked labels and every number
    /// read as data (clocks, distances, counters).
    static func mono(_ size: CGFloat, weight: Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Stand-in for "Nunito" — body copy, names, buttons.
    static func body(_ size: CGFloat, weight: Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// DM Mono labels are always uppercase, tracked out, never lighter than
/// mutedInk — this bundles that recurring pattern in one place.
struct MonoLabel: View {
    var text: String
    var size: CGFloat = 9.5
    var weight: Font.Weight = .medium
    var color: Color = Palette.mutedInk
    var tracking: CGFloat = 1.2

    var body: some View {
        Text(text.uppercased())
            .font(.mono(size, weight: weight))
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

extension View {
    /// The hard offset "sticker" shadow used on nearly every card/button —
    /// no blur, just a flat colour offset down-right.
    func hardShadow(_ color: Color = Palette.ink.opacity(0.05), x: CGFloat = 5, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: 0, x: x, y: y)
    }
}

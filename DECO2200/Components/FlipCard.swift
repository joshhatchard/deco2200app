import SwiftUI

/// The product's signature gesture: a 180° card turn between a photo face
/// and a stats face. Never replace this with a toggle.
struct FlipCard<Front: View, Back: View>: View {
    var flipped: Bool
    /// Shows a small corner affordance on the front face hinting the card turns.
    var showHint: Bool = false
    @ViewBuilder var front: () -> Front
    @ViewBuilder var back: () -> Back

    /// One-time discovery cue: until the user flips any card, the first cards
    /// they see give a brief turn so it's clear they're two-sided. Shared
    /// across every flip card so the hint shows once, not once per card type.
    @AppStorage("hasDiscoveredFlip") private var hasDiscoveredFlip = false
    @State private var wiggle = false

    var body: some View {
        ZStack {
            front().opacity(flipped ? 0 : 1)
            back()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipped ? 1 : 0)
        }
        .overlay(alignment: .topTrailing) {
            if showHint && !flipped { hintBadge }
        }
        .rotation3DEffect(.degrees(flipped ? 180 : (wiggle ? 24 : 0)),
                          axis: (x: 0, y: 1, z: 0), perspective: 0.4)
        .animation(.interpolatingSpring(stiffness: 120, damping: 14), value: flipped)
        .animation(.easeInOut(duration: 0.5), value: wiggle)
        .onChange(of: flipped) { _, isFlipped in
            // The user found the gesture — retire the hint everywhere.
            if isFlipped { hasDiscoveredFlip = true }
        }
        .onAppear {
            guard !hasDiscoveredFlip, !flipped else { return }
            // A short delay so the card is settled before it nudges.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                guard !hasDiscoveredFlip else { return }
                wiggle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { wiggle = false }
            }
        }
    }

    /// A subtle "tap to flip" sticker, matching the congrats-card language.
    private var hintBadge: some View {
        Image(systemName: "hand.tap.fill")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(Palette.ink)
            .padding(7)
            .background(Circle().fill(Palette.butter))
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.5))
            .hardShadow(Palette.ink.opacity(0.15), x: 1.5, y: 1.5)
            .padding(8)
            .allowsHitTesting(false)
            .transition(.opacity)
    }
}

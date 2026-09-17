import SwiftUI

/// The product's signature gesture: a 180° card turn between a photo face
/// and a stats face. Never replace this with a toggle.
struct FlipCard<Front: View, Back: View>: View {
    var flipped: Bool
    @ViewBuilder var front: () -> Front
    @ViewBuilder var back: () -> Back

    var body: some View {
        ZStack {
            front().opacity(flipped ? 0 : 1)
            back()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
        .animation(.interpolatingSpring(stiffness: 120, damping: 14), value: flipped)
    }
}

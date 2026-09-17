import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Post-walk gallery: review the pile and bin duds by swiping, then shake
/// to lay the survivors out as a collage. Shake again from either mode
/// reshuffles; "Use this one" moves on to the congrats card.
struct GalleryScreen: View {
    @ObservedObject var state: AppState

    private let darkInk = Color(hex: 0x123A63)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { state.go(.breakScreen) } label: {
                    Text("‹").font(.mono(15))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white))
                        .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
                        .foregroundStyle(Palette.ink)
                }
                .buttonStyle(.plain)
                Spacer()
                MonoLabel(text: "\(state.photos.count) shots", size: 10, color: darkInk, tracking: 1.4)
            }
            .padding(.horizontal, 22)
            .padding(.top, 56)

            VStack(alignment: .leading, spacing: 6) {
                Text(state.galleryMode == .review ? "Your pile" : "Shaken!")
                    .font(.display(46))
                    .foregroundStyle(Palette.ink)
                Text(state.galleryMode == .review
                     ? "Bin the duds, then shake to lay them out."
                     : "Not keen? Shake again for a new arrangement.")
                    .font(.body(14, weight: .bold))
                    .foregroundStyle(darkInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 16)

            if state.galleryMode == .review {
                ReviewDeck(state: state)
                VStack(spacing: 9) {
                    Text("Swipe up to delete\nSwipe left / right to view photos")
                        .font(.mono(9.5))
                        .tracking(1)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(darkInk)
                    Button { state.shuffle() } label: { shakeButton("Shake to collage") }
                        .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 38)
            } else {
                CollageStage(state: state)
                VStack(spacing: 10) {
                    MonoLabel(text: "Shake your phone to reshuffle", size: 9.5, color: darkInk, tracking: 1)

                    Button { state.endBreak() } label: {
                        Text("Use this one")
                            .font(.display(23, weight: .heavy))
                            .foregroundStyle(Palette.cream)
                            .frame(maxWidth: .infinity).frame(height: 60)
                            .background(Capsule().fill(Palette.ink))
                    }
                    .buttonStyle(.plain)

                    Button { state.shuffle() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.system(size: 16, weight: .bold))
                            Text("Shake again")
                                .font(.display(17, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity).frame(height: 60)
                        .background(Capsule().fill(Palette.ink.opacity(0.08)))
                        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.18), lineWidth: 1.5))
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button { state.backToReview() } label: {
                        MonoLabel(text: "Back to photos", size: 10.5, color: darkInk, tracking: 1.2)
                            .frame(maxWidth: .infinity).frame(height: 40)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 38)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.galleryBg)
        .onShake { state.shuffle() }
    }

    private func shakeButton(_ label: String) -> some View {
        Text(label)
            .font(.display(24, weight: .heavy))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Capsule().fill(Palette.butter))
            .shadow(color: Palette.ink.opacity(0.07), radius: 0, x: 0, y: 3)
    }
}

/// The draggable swipe deck: top card browses left/right, bins on a swipe up.
private struct ReviewDeck: View {
    @ObservedObject var state: AppState
    @State private var drag: CGSize = .zero

    private var pool: [PhotoShot] {
        state.photos.isEmpty ? [PhotoShot(index: 0, caption: "nothing yet")] : state.photos
    }

    var body: some View {
        ZStack {
            ForEach(visibleDepths.reversed(), id: \.self) { depth in
                card(depth: depth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var visibleDepths: [Int] {
        [2, 1, 0].filter { $0 < pool.count }
    }

    private func card(depth: Int) -> some View {
        let n = pool.count
        let idx = (state.cardIndex + depth) % n
        let shot = pool[idx]
        let isTop = depth == 0
        let slide = isTop ? drag.width : 0
        let lift = isTop ? drag.height : 0
        let binning = lift < -40
        let dragging = isTop && (drag.width != 0 || drag.height != 0)

        return VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Palette.tileColor(hue: state.currentHue, seed: shot.index + state.seed))
                #if canImport(UIKit)
                if let data = shot.imageData,
                   let ui = ImageCache.image(key: shot.id.uuidString, data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                }
                #endif
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

            HStack(alignment: .lastTextBaseline) {
                Text(shot.caption).font(.display(13, weight: .bold)).foregroundStyle(Palette.ink)
                Spacer()
                Text("\(idx + 1) / \(n)").font(.mono(10)).foregroundStyle(Palette.mutedInk)
            }
            .padding(.top, 9)

            if isTop {
                Text("Bin it")
                    .font(.display(13, weight: .heavy))
                    .foregroundStyle(Palette.cream)
                    .frame(width: 68)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Palette.coral))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .opacity(binning ? 1 : 0)
                    .padding(.top, 5)
            }
        }
        .padding(EdgeInsets(top: 11, leading: 11, bottom: 8, trailing: 11))
        .frame(width: 200)
        .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.white))
        .shadow(color: Palette.ink.opacity(0.07 - Double(depth) * 0.02), radius: 0, x: 4, y: 4)
        .offset(x: slide + CGFloat(depth) * 6, y: lift + CGFloat(depth) * 5)
        .rotationEffect(.degrees(slide / 22 + Double(depth) * 2.5))
        .scaleEffect(1 - Double(depth) * 0.04)
        .opacity(binning ? 0.55 : 1)
        .zIndex(Double(10 - depth))
        .animation(dragging ? nil : .interpolatingSpring(stiffness: 220, damping: 20), value: drag)
        .gesture(dragGesture(isTop: isTop))
    }

    private func dragGesture(isTop: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard isTop else { return }
                drag = value.translation
            }
            .onEnded { value in
                guard isTop else { return }
                let n = pool.count
                if value.translation.height < -80 && abs(value.translation.height) > abs(value.translation.width) {
                    if !state.photos.isEmpty { state.deleteShot(at: state.cardIndex) }
                } else if abs(value.translation.width) > 70 && n > 1 {
                    state.browse(by: value.translation.width < 0 ? 1 : -1)
                }
                drag = .zero
            }
    }
}

/// The landed collage — a rotated white card with the same proportional
/// row layout used everywhere else, re-keyed by seed so shake feels like a
/// real re-composition.
private struct CollageStage: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollageView(count: state.photos.count, seed: state.seed, hue: state.currentHue, gap: 5, animateIn: true,
                        photos: state.photos.map(\.imageData))
                .id(state.seed)
                .aspectRatio(1, contentMode: .fit)
            HStack(alignment: .lastTextBaseline) {
                Text(state.themeTitle).font(.display(15, weight: .heavy))
                Spacer()
                Text("\(state.photos.count) photos").font(.mono(10)).foregroundStyle(Palette.mutedInk)
            }
            .padding(.top, 10)
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 14, trailing: 12))
        .frame(maxWidth: 300)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(.white))
        .hardShadow(Palette.ink.opacity(0.07), x: 4, y: 4)
        .rotationEffect(.degrees(-1.4))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shake gesture

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    /// UIKit delivers the physical shake here; rebroadcast it so SwiftUI can
    /// listen. The Simulator's Device ▸ Shake Gesture triggers this too.
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

extension View {
    /// Runs `action` whenever the device is physically shaken. Bridges the
    /// UIKit motion event through an async notification stream (no Combine);
    /// the `.task` is scoped to the view, so it only listens while on screen.
    func onShake(perform action: @escaping () -> Void) -> some View {
        task {
            for await _ in NotificationCenter.default.notifications(named: UIDevice.deviceDidShakeNotification) {
                action()
            }
        }
    }
}

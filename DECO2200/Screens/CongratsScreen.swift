import SwiftUI

struct CongratsScreen: View {
    @ObservedObject var state: AppState

    var body: some View {
        ZStack {
            decorations

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    MonoLabel(text: "Hunt · \(state.themeTitle)", size: 10, tracking: 1.6)
                    Text(state.congratsHeadline)
                        .font(.display(42))
                        .foregroundStyle(Palette.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 56)

                FlipCard(flipped: state.flipped) {
                    front
                } back: {
                    back
                }
                .aspectRatio(0.84, contentMode: .fit)
                .frame(maxWidth: 322)
                .rotationEffect(.degrees(-1.6))
                .contentShape(Rectangle())
                .onTapGesture { flip() }
                .gesture(
                    DragGesture(minimumDistance: 24)
                        .onEnded { value in
                            if abs(value.translation.width) > 40 { flip() }
                        }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)

                VStack(spacing: 9) {
                    Button { state.go(.share) } label: {
                        Text("Share it")
                            .font(.display(22, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity).frame(height: 60)
                            .background(Capsule().fill(Palette.green))
                            .shadow(color: Palette.ink.opacity(0.06), radius: 0, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    Button { state.go(.home) } label: {
                        MonoLabel(text: "Keep it to myself", size: 11, tracking: 1.2)
                            .frame(maxWidth: .infinity).frame(height: 46)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 38)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.homeBg)
    }

    private func flip() {
        state.flipped.toggle()
    }

    private var decorations: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6).fill(Palette.butter).frame(width: 22, height: 22)
                .rotationEffect(.degrees(24)).position(x: 40, y: 130)
            Circle().fill(Palette.lilac).frame(width: 16, height: 16)
                .position(x: 330, y: 108)
            RoundedRectangle(cornerRadius: 8).fill(Palette.sky).frame(width: 26, height: 26)
                .rotationEffect(.degrees(-16)).position(x: 350, y: 220)
        }
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollageView(count: state.photos.count, seed: state.seed, hue: state.currentHue, gap: 5,
                        photos: state.photos.map(\.imageData))
                .frame(maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            HStack {
                Text(state.themeTitle).font(.display(21, weight: .heavy))
                Spacer()
            }
            .padding(.top, 14)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white))
        .hardShadow(Palette.ink.opacity(0.06), x: 4, y: 4)
        .overlay(alignment: .topTrailing) { flipSticker }
    }

    /// Playful corner sticker cueing that the card flips.
    private var flipSticker: some View {
        HStack(spacing: 5) {
            Image(systemName: "hand.tap.fill").font(.system(size: 11, weight: .black))
            Text("flip me!").font(.display(13, weight: .heavy))
        }
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(Palette.butter))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 2))
        .hardShadow(Palette.ink.opacity(0.18), x: 2, y: 2)
        .rotationEffect(.degrees(8))
        .offset(x: 8, y: -12)
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel(text: "Break time", size: 10, color: Palette.ink, tracking: 1.6)
            Text(state.formattedElapsed).font(.mono(46, weight: .medium)).foregroundStyle(Palette.ink)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(state.photos.count)").font(.display(40, weight: .heavy)).foregroundStyle(Palette.ink)
                    MonoLabel(text: "Photos", size: 9.5, color: Palette.ink, tracking: 1)
                }
                .padding(14)
                .frame(width: 104, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.6)))

                VStack(alignment: .leading, spacing: 0) {
                    MonoLabel(text: "Route", size: 9.5, color: Palette.ink, tracking: 1)
                    Text("1.4 km").font(.display(30, weight: .heavy)).foregroundStyle(Palette.ink).padding(.top, 2)
                    RouteDots(color: Palette.ink, dotCount: 4).frame(height: 44).padding(.top, 8)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.6)))
            }
            .padding(.top, 16)

            if let memo = state.voiceMemo {
                VoiceMemoPlayButton(data: memo)
                    .padding(.top, 14)
            }

            Spacer(minLength: 0)
            MonoLabel(text: "Flip back", size: 9.5, color: Palette.ink, tracking: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(state.currentHue))
        .hardShadow(Palette.ink.opacity(0.06), x: 4, y: 4)
    }
}

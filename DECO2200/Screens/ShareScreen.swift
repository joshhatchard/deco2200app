import SwiftUI

private struct Audience: Identifiable {
    let id: String
    let title: String
    let blurb: String
    let hue: Color
}

private let audiences: [Audience] = [
    Audience(id: "group", title: "Walking Club", blurb: "7 friends · they see your route", hue: Palette.mint),
    Audience(id: "close", title: "Close pals", blurb: "3 people · stats hidden", hue: Palette.butter),
    Audience(id: "public", title: "Everyone", blurb: "Public feed · route hidden", hue: Palette.sky)
]

struct ShareScreen: View {
    @ObservedObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { state.go(.congrats) } label: {
                    Text("‹").font(.mono(15))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white))
                        .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
                        .foregroundStyle(Palette.ink)
                }
                .buttonStyle(.plain)
                Spacer()
                MonoLabel(text: "Last bit", size: 10, tracking: 1.4)
            }
            .padding(.horizontal, 22)
            .padding(.top, 56)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Who gets to see it?")
                        .font(.display(40))
                        .foregroundStyle(Palette.ink)

                    VStack(spacing: 12) {
                        ForEach(audiences) { a in audienceCard(a) }
                    }
                    .padding(.top, 20)

                    Text("Preview")
                        .font(.display(18, weight: .bold))
                        .padding(.top, 24).padding(.bottom, 12)

                    previewCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }

            Button {
                state.post()
            } label: {
                Text(state.postLabel)
                    .font(.display(21, weight: .bold))
                    .foregroundStyle(Palette.cream)
                    .frame(maxWidth: .infinity).frame(height: 60)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.shareBg)
    }

    private func audienceCard(_ a: Audience) -> some View {
        let selected = state.audience == a.id
        return HStack(spacing: 13) {
            BlobFace(size: 40, color: .white.opacity(0.6))
            VStack(alignment: .leading, spacing: 2) {
                Text(a.title).font(.display(22, weight: .heavy)).foregroundStyle(Palette.ink)
                Text(a.blurb).font(.body(12.5, weight: .semibold)).foregroundStyle(Palette.ink.opacity(0.75))
            }
            Spacer(minLength: 0)
            Circle()
                .fill(selected ? Palette.ink : Color.clear)
                .overlay(Circle().strokeBorder(selected ? Color.clear : Palette.ink.opacity(0.3), lineWidth: 2.5))
                .frame(width: 26, height: 26)
        }
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(a.hue))
        .shadow(color: Palette.ink.opacity(selected ? 0.08 : 0.05), radius: 0, x: selected ? 4 : 3, y: selected ? 4 : 3)
        .rotationEffect(.degrees(selected ? -1.2 : 0))
        .contentShape(Rectangle())
        .onTapGesture { state.audience = a.id }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollageView(count: state.photos.count, seed: state.seed, hue: state.currentHue, gap: 4)
                .aspectRatio(1, contentMode: .fit)
            HStack {
                Text(state.themeTitle).font(.display(17, weight: .heavy))
                Spacer()
                Text("\(state.formattedElapsed) · \(state.photos.count)").font(.mono(11)).foregroundStyle(Palette.ink)
            }
            .padding(.top, 11)
        }
        .padding(EdgeInsets(top: 11, leading: 11, bottom: 16, trailing: 11))
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white))
        .hardShadow(Palette.ink.opacity(0.05), x: 4, y: 4)
        .rotationEffect(.degrees(-1.2))
    }
}

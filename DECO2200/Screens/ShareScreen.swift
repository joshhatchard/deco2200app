import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

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
    @Environment(\.modelContext) private var modelContext
    @State private var shareURL: URL?

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

            VStack(spacing: 10) {
                #if canImport(UIKit)
                if let shareURL {
                    ShareLink(item: shareURL) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 15, weight: .bold))
                            Text("Export / send image").font(.display(16, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Capsule().fill(Palette.ink.opacity(0.08)))
                        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.18), lineWidth: 1.5))
                        .contentShape(Capsule())
                    }
                }
                #endif

                Button {
                    savePost()
                    state.post()
                } label: {
                    Text(state.postLabel)
                        .font(.display(21, weight: .bold))
                        .foregroundStyle(Palette.cream)
                        .frame(maxWidth: .infinity).frame(height: 60)
                        .background(Capsule().fill(Palette.ink))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.shareBg)
        #if canImport(UIKit)
        .onAppear { prepareShareURL() }
        #endif
    }

    // MARK: - Export & persist

    #if canImport(UIKit)
    @MainActor private func currentCollageImage() -> UIImage? {
        renderCollageImage(count: state.photos.count, seed: state.seed,
                           hue: state.currentHue, photos: state.photos.map(\.imageData))
    }

    @MainActor private func prepareShareURL() {
        // Share a self-contained polaroid (collage + title + time), not the
        // bare collage that the in-app feed frames itself.
        guard let image = renderPolaroidImage(theme: state.themeTitle,
                                              timeString: state.formattedElapsed,
                                              count: state.photos.count,
                                              seed: state.seed,
                                              hue: state.currentHue,
                                              photos: state.photos.map(\.imageData)),
              let data = image.jpegData(compressionQuality: 0.9) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("scrapmap-collage.jpg")
        if (try? data.write(to: url)) != nil { shareURL = url }
    }
    #endif

    @MainActor private func savePost() {
        #if canImport(UIKit)
        guard let image = currentCollageImage(),
              let data = image.jpegData(compressionQuality: 0.9) else { return }
        let ui = UIColor(state.currentHue)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let saved = SavedCollage(theme: state.themeTitle,
                                 timeString: state.formattedElapsed,
                                 count: state.photos.count,
                                 distance: "1.4 km",
                                 hueRed: Double(r), hueGreen: Double(g), hueBlue: Double(b),
                                 imageData: data)
        modelContext.insert(saved)
        try? modelContext.save()
        #endif
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
            CollageView(count: state.photos.count, seed: state.seed, hue: state.currentHue, gap: 4,
                        photos: state.photos.map(\.imageData))
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

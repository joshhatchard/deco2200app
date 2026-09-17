import SwiftUI

struct ProfileScreen: View {
    @ObservedObject var state: AppState

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    statsRow.padding(.top, 22).padding(.bottom, 24)
                    sectionRule.padding(.bottom, 16)
                    scrapbookGrid
                }
                .padding(20)
                .padding(.top, 36)
            }
            FloatingTabBar(active: .profile, surroundingBg: Palette.profileBg,
                           onFeed: { state.go(.home) },
                           onCreate: { state.go(.theme) },
                           onProfile: { state.go(.profile) })
                .padding(.bottom, 10)
        }
        .background(Palette.profileBg)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 15) {
            BlobFace(size: 78, color: Palette.mint, showSmile: true)
                .hardShadow(Palette.ink.opacity(0.05), x: 3, y: 3)
            VStack(alignment: .leading, spacing: 3) {
                Text("Maya Okonkwo").font(.display(28)).foregroundStyle(Palette.ink)
                Text("@mayawalks").font(.mono(10.5)).foregroundStyle(Palette.mutedInk)
                HStack(spacing: 8) {
                    followPill(count: 248, label: "followers")
                    followPill(count: 186, label: "following")
                }
                .padding(.top, 9)
            }
        }
    }

    private func followPill(count: Int, label: String) -> some View {
        (Text("\(count) ").font(.mono(11, weight: .bold)) + Text(label).font(.mono(11)))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 11).padding(.vertical, 5)
            .background(Capsule().fill(Palette.ink.opacity(0.08)))
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statTile(value: "\(state.streak)", label: "Day streak", hue: Palette.butter, tilt: -1.2)
            statTile(value: "\(state.myScrapbook.count + 18)", label: "Scraps", hue: Palette.coral, tilt: 1.2)
            statTile(value: "214", label: "Photos", hue: Palette.sky, tilt: -1.2)
        }
    }

    private func statTile(value: String, label: String, hue: Color, tilt: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(.display(34, weight: .heavy)).foregroundStyle(Palette.ink)
            MonoLabel(text: label, size: 9.5, color: Palette.ink, tracking: 1)
        }
        .padding(EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(hue))
        .shadow(color: Palette.ink.opacity(0.05), radius: 0, x: 3, y: 3)
        .rotationEffect(.degrees(tilt))
    }

    private var sectionRule: some View {
        HStack(spacing: 9) {
            Text("My scrapbook").font(.display(20, weight: .bold))
            Rectangle().fill(Palette.ink.opacity(0.12)).frame(height: 3).clipShape(Capsule())
        }
    }

    private var scrapbookGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 16)]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(state.myScrapbook.enumerated()), id: \.offset) { i, scrap in
                scrapTile(scrap, tilt: i % 2 == 0 ? -1.8 : 1.6)
            }
        }
    }

    private func scrapTile(_ scrap: ScrapPost, tilt: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: gridColumns, spacing: 3) {
                ForEach(0..<9, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Palette.tileColor(hue: scrap.hue, seed: scrap.seed + i))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            Text(scrap.theme).font(.display(14, weight: .bold)).foregroundStyle(Palette.ink)
                .lineLimit(2)
                .padding(.top, 8)
            Text(scrap.time).font(.mono(9.5)).foregroundStyle(Palette.mutedInk)
        }
        .padding(EdgeInsets(top: 9, leading: 9, bottom: 11, trailing: 9))
        .frame(width: 150, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(.white))
        .hardShadow(Palette.ink.opacity(0.05), x: 3, y: 3)
        .overlay(alignment: .top) {
            Circle().fill(scrap.hue).frame(width: 14, height: 14)
                .shadow(color: Palette.ink.opacity(0.08), radius: 0, x: 0, y: 1)
                .offset(y: -7)
        }
        .rotationEffect(.degrees(tilt))
    }
}

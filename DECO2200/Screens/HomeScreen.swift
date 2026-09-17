import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct HomeScreen: View {
    @ObservedObject var state: AppState
    @State private var dotPulse = false
    @Query(sort: \SavedCollage.createdAt, order: .reverse) private var savedCollages: [SavedCollage]

    private let dayHues: [Color?] = [Palette.butter, Palette.sky, Palette.coral, Palette.mint, Palette.lilac, nil, nil]
    private let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    huntHero
                    streakCard
                        .padding(.top, 22)
                    sectionRule(title: "Fresh scraps")
                        .padding(.top, 26)
                        .padding(.bottom, 14)
                    feedList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            FloatingTabBar(active: .feed, surroundingBg: Palette.homeBg,
                           onFeed: { state.go(.home) },
                           onCreate: { state.go(.theme) },
                           onProfile: { state.go(.profile) })
                .padding(.bottom, 10)
        }
        .background(Palette.homeBg)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Wordmark(size: 30)
                MonoLabel(text: "Sitting 1h 52m", size: 10)
            }
            Spacer()
            HStack(spacing: 8) {
                circleIcon { Text("+").font(.display(22)).foregroundStyle(Palette.ink) }
                circleIcon {
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 4).fill(Palette.ink).frame(width: 13, height: 13)
                        Circle().fill(Palette.green).frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Palette.homeBg, lineWidth: 2))
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 4)
    }

    private func circleIcon<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: 40, height: 40)
            .background(Circle().fill(.white))
            .hardShadow(Palette.ink.opacity(0.04), x: 2, y: 2)
    }

    private var huntHero: some View {
        ZStack(alignment: .topTrailing) {
            BlobFace(size: 64, color: .white.opacity(0.28), showEars: true, showSmile: true, bob: true)
                .offset(x: 14, y: -12)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Circle().fill(Palette.ink).frame(width: 9, height: 9)
                        .opacity(dotPulse ? 1 : 0.25)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                                dotPulse = true
                            }
                        }
                    MonoLabel(text: "Today's hunt · Gone in \(countdownToMidnight())", size: 9.5, color: Palette.ink, tracking: 1.5)
                }
                Text(Hunts.daily.title)
                    .font(.display(44))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .frame(maxWidth: 200, alignment: .leading)
                    .padding(.top, 6)
                Text("\(Hunts.dailyPeopleOut) out on it today.")
                    .font(.body(13, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 6)
                HStack(spacing: 8) {
                    Text("Start hunting").font(.display(19, weight: .heavy))
                    Text("›").font(.mono(15, weight: .medium))
                }
                .foregroundStyle(Palette.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Palette.ink))
                .padding(.top, 16)
            }
        }
        .padding(EdgeInsets(top: 20, leading: 18, bottom: 18, trailing: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Palette.green))
        .hardShadow(Palette.ink.opacity(0.06), x: 4, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { state.go(.theme) }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel(text: "Streak", size: 9.5, tracking: 1.4)
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(state.streak)").font(.display(58)).foregroundStyle(Palette.ink)
                Text("days").font(.body(12.5, weight: .bold)).foregroundStyle(Palette.ink)
                Spacer()
                MonoLabel(text: "Best \(state.bestStreak)", size: 10, color: Palette.ink, tracking: 0.6)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Capsule().fill(Palette.ink.opacity(0.08)))
            }
            HStack(spacing: 5) {
                ForEach(0..<7, id: \.self) { i in dayCell(i) }
            }
            .padding(.top, 14)
            MonoLabel(text: "Ticks are days you finished a hunt", size: 9, tracking: 1)
                .padding(.top, 9)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.white))
        .hardShadow(Palette.ink.opacity(0.04), x: 3, y: 3)
    }

    private func dayCell(_ i: Int) -> some View {
        let done = i < 5, today = i == 5
        return VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(done ? (dayHues[i] ?? Palette.ink) : Color.clear)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(today ? Palette.ink : Color.clear, lineWidth: 2.5)
                )
                .overlay {
                    if done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(done || today ? Color.clear : Palette.ink.opacity(0.08))
                )
            Text(dayLetters[i])
                .font(.mono(10, weight: .medium))
                .foregroundStyle(done || today ? Palette.ink : Palette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionRule(title: String) -> some View {
        HStack(spacing: 9) {
            Text(title).font(.display(20, weight: .bold))
            Rectangle().fill(Palette.ink.opacity(0.12)).frame(height: 3).clipShape(Capsule())
        }
    }

    private var feedList: some View {
        VStack(spacing: 30) {
            ForEach(savedCollages) { saved in
                SavedFeedCard(saved: saved)
            }
            ForEach(state.feed) { post in
                FeedCard(post: post,
                         onFlip: { state.toggleFlip(post) },
                         onLike: { state.toggleLike(post) })
            }
        }
    }
}

/// A persisted, user-posted collage rendered as a flip feed card — front shows
/// the stored collage image, back shows the walk stats, matching other cards.
private struct SavedFeedCard: View {
    let saved: SavedCollage
    @State private var flipped = false

    var body: some View {
        VStack(spacing: 0) {
            PolaroidFrame(pinColor: saved.hue) {
                FlipCard(flipped: flipped) {
                    front
                } back: {
                    back
                }
                .aspectRatio(0.92, contentMode: .fit)
                .contentShape(Rectangle())
                .onTapGesture { flipped.toggle() }
            }

            HStack(spacing: 13) {
                Circle().fill(saved.hue).frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("You").font(.body(13.5, weight: .heavy))
                    Text("\(saved.timeString) · \(saved.count) photos")
                        .font(.mono(9.5)).foregroundStyle(Palette.mutedInk)
                }
                Spacer(minLength: 8)
            }
            .padding(.top, 12)
        }
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: 0) {
            collageImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            HStack {
                Text(saved.theme).font(.display(19, weight: .bold))
                Spacer()
                MonoLabel(text: "Tap = stats", size: 9.5, tracking: 1)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel(text: "Break time", size: 10, color: Palette.ink, tracking: 1.4)
            Text(saved.timeString).font(.mono(40, weight: .medium)).foregroundStyle(Palette.ink)
            HStack(spacing: 9) {
                statTile(value: "\(saved.count)", label: "Photos")
                statTile(value: saved.distance, label: "Route")
            }
            .padding(.top, 14)
            Spacer(minLength: 0)
            MonoLabel(text: "Tap = photos", size: 9.5, color: Palette.ink, tracking: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(saved.hue))
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.display(26, weight: .heavy)).foregroundStyle(Palette.ink)
            MonoLabel(text: label, size: 9.5, color: Palette.ink, tracking: 1)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white.opacity(0.55)))
    }

    @ViewBuilder private var collageImage: some View {
        #if canImport(UIKit)
        if let ui = ImageCache.image(key: "\(saved.persistentModelID)", data: saved.imageData) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            Rectangle().fill(saved.hue.opacity(0.2))
        }
        #else
        Rectangle().fill(saved.hue.opacity(0.2))
        #endif
    }
}

private struct FeedCard: View {
    var post: ScrapPost
    var onFlip: () -> Void
    var onLike: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PolaroidFrame(pinColor: post.hue, tilt: 0, pinSize: 18) {
                FlipCard(flipped: post.flipped) {
                    front
                } back: {
                    back
                }
                .aspectRatio(0.92, contentMode: .fit)
                .contentShape(Rectangle())
                .onTapGesture { onFlip() }
            }

            HStack(spacing: 13) {
                Circle().fill(post.hue).frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.name).font(.body(13.5, weight: .heavy))
                    Text(post.meta).font(.mono(9.5)).foregroundStyle(Palette.mutedInk)
                }
                Spacer(minLength: 8)
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        heart
                        Text("\(post.likes)").font(.mono(12, weight: .medium))
                    }
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(Capsule().fill(Palette.ink.opacity(0.06)))
                }
                .buttonStyle(.plain)
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 5).strokeBorder(Palette.ink, lineWidth: 2)
                        .frame(width: 14, height: 12)
                    Text("\(post.comments)").font(.mono(12, weight: .medium))
                }
                .padding(.horizontal, 11).padding(.vertical, 6)
                .background(Capsule().fill(Palette.ink.opacity(0.06)))
            }
            .padding(.top, 12)
        }
    }

    private var heart: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(post.liked ? Palette.coral : Color.clear)
            .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(post.liked ? Color.clear : Palette.ink, lineWidth: 2))
            .frame(width: 15, height: 15)
            .rotationEffect(.degrees(45))
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollageView(count: post.count, seed: post.seed, hue: post.hue, gap: 4)
                .frame(maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            HStack {
                Text(post.theme).font(.display(19, weight: .bold))
                Spacer()
                MonoLabel(text: "Tap = stats", size: 9.5, tracking: 1)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 0) {
            MonoLabel(text: "Break time", size: 10, color: Palette.ink, tracking: 1.4)
            Text(post.time).font(.mono(42, weight: .medium)).foregroundStyle(Palette.ink)
            HStack(spacing: 9) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(post.count)").font(.display(34, weight: .heavy)).foregroundStyle(Palette.ink)
                    MonoLabel(text: "Photos", size: 9.5, color: Palette.ink, tracking: 1)
                }
                .padding(13)
                .frame(width: 96, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white.opacity(0.55)))

                VStack(alignment: .leading, spacing: 0) {
                    MonoLabel(text: "Route", size: 9.5, color: Palette.ink, tracking: 1)
                    Text(post.distance).font(.display(26, weight: .heavy)).foregroundStyle(Palette.ink).padding(.top, 2)
                    RouteDots(color: Palette.ink, dotCount: 3).frame(height: 34).padding(.top, 8)
                }
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white.opacity(0.55)))
            }
            .padding(.top, 14)
            Spacer(minLength: 0)
            MonoLabel(text: "Tap = photos", size: 9.5, color: Palette.ink, tracking: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(post.hue))
    }
}

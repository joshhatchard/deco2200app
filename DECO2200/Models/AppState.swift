import SwiftUI
import Combine
import Foundation

enum Screen: String, Equatable {
    case home, nudge, theme, breakScreen, gallery, congrats, share, profile
}

enum GalleryMode: Equatable {
    case review, collage
}

/// Ports the single `Component` class from the prototype's `<script
/// data-dc-script>` — one state object driving the whole loop:
/// nudge → theme → walk and shoot → shuffle → flip → share.
@MainActor
final class AppState: ObservableObject {
    @Published var screen: Screen = .home
    @Published var themeId: String = "daily"
    @Published var customTheme: String = ""

    @Published var photos: [PhotoShot] = []
    @Published var elapsedSeconds: Int = 0
    @Published var seed: Int = 1

    @Published var galleryMode: GalleryMode = .review
    @Published var cardIndex: Int = 0
    @Published var flipped: Bool = false

    @Published var audience: String = "group"
    @Published var feed: [ScrapPost] = SeedData.othersFeed
    @Published var streak: Int = 13
    let bestStreak = 21

    private var timer: AnyCancellable?

    // MARK: - Navigation

    func go(_ screen: Screen) {
        // The hunt page always opens on today's hunt, regardless of any
        // freestyle/custom pick made on a previous visit.
        if screen == .theme { themeId = "daily" }
        self.screen = screen
    }

    // MARK: - Theme selection

    var isCustomTheme: Bool { themeId == "custom" }
    var isDailyTheme: Bool { themeId == "daily" }

    var currentHue: Color {
        if isDailyTheme { return Hunts.daily.hue }
        if isCustomTheme { return Palette.lilac }
        return Hunts.theme(for: themeId)?.hue ?? Hunts.freestyle[0].hue
    }

    var themeTitle: String {
        if isDailyTheme { return Hunts.daily.title }
        if isCustomTheme { return customTheme.isEmpty ? "My own hunt" : customTheme }
        return Hunts.theme(for: themeId)?.title ?? Hunts.freestyle[0].title
    }

    var huntKind: String {
        isDailyTheme ? "Today's hunt · everyone" : "Freestyle"
    }

    func pickDaily() { themeId = "daily" }
    func selectTheme(_ id: String) { themeId = id }
    func selectCustom() { themeId = "custom" }

    // MARK: - Break / capture

    /// While the walk (`breakScreen`) or the post-walk gallery is on
    /// screen, the clock keeps running.
    func syncTimer() {
        timer?.cancel()
        guard screen == .breakScreen || screen == .gallery else { return }
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.elapsedSeconds += 1 }
    }

    func startBreak() {
        photos = []
        deletedShots = []
        elapsedSeconds = 0
        screen = .breakScreen
        WalkLiveActivity.start(theme: themeTitle, hue: currentHue, startDate: Date())
    }

    func capture(imageData: Data? = nil) {
        photos.append(PhotoShot(index: photos.count, caption: "shot \(photos.count + 1)", imageData: imageData))
        WalkLiveActivity.update(photoCount: photos.count)
    }

    /// Caller must ensure there's at least one photo; the walk can't be
    /// finished empty.
    func finishShooting() {
        deletedShots = []
        galleryMode = .review
        cardIndex = 0
        screen = .gallery
        // Live Activity keeps running through review/collage — it only ends
        // once the walk is confirmed via "Use this one" (endBreak).
    }

    // MARK: - Gallery review deck

    private struct DeletedShot { let shot: PhotoShot; let index: Int }
    @Published private var deletedShots: [DeletedShot] = []

    var canUndo: Bool { !deletedShots.isEmpty }

    func deleteShot(at index: Int) {
        guard photos.indices.contains(index) else { return }
        let removed = photos.remove(at: index)
        deletedShots.append(DeletedShot(shot: removed, index: index))
        cardIndex = min(cardIndex, max(0, photos.count - 1))
        WalkLiveActivity.update(photoCount: photos.count)
    }

    /// Restore the most recently binned photo to where it was.
    func undoDelete() {
        guard let last = deletedShots.popLast() else { return }
        let insertIndex = min(last.index, photos.count)
        photos.insert(last.shot, at: insertIndex)
        cardIndex = insertIndex
        WalkLiveActivity.update(photoCount: photos.count)
    }

    func browse(by delta: Int) {
        guard !photos.isEmpty else { return }
        let n = photos.count
        cardIndex = ((cardIndex + delta) % n + n) % n
    }

    func backToReview() {
        galleryMode = .review
    }

    /// Shake: wobble the pile, then land it as a collage. Shaking again
    /// (from either mode) reshuffles the arrangement in place.
    func shuffle() {
        seed += 1
        withAnimation(.easeInOut(duration: 0.56)) {
            galleryMode = .collage
        }
    }

    /// "Use this one" — the walk is confirmed here, so the Live Activity ends
    /// and disappears immediately.
    func endBreak() {
        WalkLiveActivity.end()
        flipped = false
        screen = .congrats
    }

    // MARK: - Share / post

    /// The posted collage itself is persisted via SwiftData in the share
    /// screen (so it survives relaunch and stays on the feed); here we just
    /// bump the streak, clear the walk, and return home.
    func post() {
        streak += 1
        photos = []
        elapsedSeconds = 0
        screen = .home
    }

    var postLabel: String {
        switch audience {
        case "public": return "Post to everyone"
        case "close": return "Post to close pals"
        default: return "Post to Walking Club"
        }
    }

    // MARK: - Feed interactions

    func toggleFlip(_ post: ScrapPost) {
        guard let i = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[i].flipped.toggle()
    }

    func toggleLike(_ post: ScrapPost) {
        guard let i = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[i].liked.toggle()
        feed[i].likes += feed[i].liked ? 1 : -1
    }

    // MARK: - Derived display values

    var formattedElapsed: String { Self.format(elapsedSeconds) }

    static func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    static func formatLong(_ seconds: Int) -> String {
        "00:" + format(seconds)
    }

    var congratsHeadline: String {
        let n = photos.count
        if n >= 12 { return "What a haul!" }
        if n <= 4 { return "Short and sweet." }
        return "Nice haul."
    }

    var myScrapbook: [ScrapPost] {
        feed.filter { $0.name == "Maya Okonkwo" } + SeedData.profileHistory
    }
}

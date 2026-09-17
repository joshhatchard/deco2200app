import SwiftUI

/// A single completed walk — shown as a flip card in the feed and, for the
/// signed-in user's own posts, in the profile scrapbook grid.
struct ScrapPost: Identifiable {
    let id = UUID()
    var name: String
    var meta: String
    var theme: String
    var seed: Int
    var time: String
    var count: Int
    var distance: String = "1.4 km"
    var hue: Color
    var likes: Int = 0
    var comments: Int = 0
    var liked: Bool = false
    var flipped: Bool = false
}

/// A single photo taken during a break. `index` is assigned at capture
/// time and never renumbered, so deleting shots doesn't shuffle the
/// placeholder tint of the ones that remain.
struct PhotoShot: Identifiable {
    let id = UUID()
    let index: Int
    var caption: String
    /// Encoded camera capture (JPEG/HEIC). Nil for the demo-fallback shots,
    /// which render as tinted placeholder tiles.
    var imageData: Data? = nil
}

enum SeedData {
    /// Other people's posts already in the feed.
    static let othersFeed: [ScrapPost] = [
        ScrapPost(name: "Devon Achebe", meta: "2h ago · Riverside loop", theme: "Look up", seed: 3,
                  time: "00:24:10", count: 5, distance: "1.9 km", hue: Palette.mint, likes: 14, comments: 3),
        ScrapPost(name: "Priya Raman", meta: "Yesterday · Old town", theme: "Look up", seed: 7,
                  time: "00:41:02", count: 17, distance: "2.6 km", hue: Palette.mint, likes: 31, comments: 6)
    ]

    /// Scrapbook history that predates this session — profile-only, not
    /// part of the shared feed.
    static let profileHistory: [ScrapPost] = [
        ScrapPost(name: "Maya Okonkwo", meta: "", theme: "10 round things", seed: 5, time: "00:18:40", count: 9, hue: Palette.butter),
        ScrapPost(name: "Maya Okonkwo", meta: "", theme: "Doorways", seed: 11, time: "00:32:35", count: 9, hue: Palette.sky),
        ScrapPost(name: "Maya Okonkwo", meta: "", theme: "Something red", seed: 2, time: "00:26:04", count: 9, hue: Palette.coral)
    ]
}

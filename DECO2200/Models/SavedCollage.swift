import SwiftUI
import SwiftData

/// A collage the user posted, persisted on-device so it stays on the feed
/// across app launches. Stores a pre-rendered collage image (used both for the
/// feed and for exporting/sharing) plus the metadata shown on the card.
@Model
final class SavedCollage {
    var createdAt: Date
    var theme: String
    var timeString: String
    var count: Int
    var distance: String
    var hueRed: Double
    var hueGreen: Double
    var hueBlue: Double
    @Attribute(.externalStorage) var imageData: Data

    init(createdAt: Date = Date(),
         theme: String,
         timeString: String,
         count: Int,
         distance: String,
         hueRed: Double,
         hueGreen: Double,
         hueBlue: Double,
         imageData: Data) {
        self.createdAt = createdAt
        self.theme = theme
        self.timeString = timeString
        self.count = count
        self.distance = distance
        self.hueRed = hueRed
        self.hueGreen = hueGreen
        self.hueBlue = hueBlue
        self.imageData = imageData
    }

    var hue: Color { Color(.sRGB, red: hueRed, green: hueGreen, blue: hueBlue) }
}

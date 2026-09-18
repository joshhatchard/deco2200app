import ActivityKit
import SwiftUI

/// Shared Live Activity model for the walk. This file must belong to BOTH the
/// app target (to start/update/end the activity) and the WalkActivity widget
/// target (to render it).
struct WalkActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Number of photos taken so far — updated as the walk goes.
        var photoCount: Int
    }

    /// Fixed for the life of the activity.
    var theme: String
    var startDate: Date
    var hueRed: Double
    var hueGreen: Double
    var hueBlue: Double

    var hue: Color { Color(.sRGB, red: hueRed, green: hueGreen, blue: hueBlue) }
}

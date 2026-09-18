import Foundation
import SwiftUI
#if canImport(ActivityKit)
import ActivityKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Thin wrapper around the walk Live Activity so the rest of the app can
/// start/update/end it without touching ActivityKit directly. All no-ops if
/// Live Activities are unavailable or disabled.
enum WalkLiveActivity {
    #if canImport(ActivityKit)
    @MainActor private static var activity: Activity<WalkActivityAttributes>?

    @MainActor static func start(theme: String, hue: Color, startDate: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end() // clear any stale activity first
        let rgb = hue.rgbComponents
        let attributes = WalkActivityAttributes(theme: theme, startDate: startDate,
                                                hueRed: rgb.r, hueGreen: rgb.g, hueBlue: rgb.b)
        let state = WalkActivityAttributes.ContentState(photoCount: 0)
        activity = try? Activity.request(attributes: attributes,
                                         content: .init(state: state, staleDate: nil))
    }

    @MainActor static func update(photoCount: Int) {
        guard let activity else { return }
        let state = WalkActivityAttributes.ContentState(photoCount: photoCount)
        Task { await activity.update(.init(state: state, staleDate: nil)) }
    }

    @MainActor static func end() {
        guard let activity else { return }
        let finishing = activity
        self.activity = nil
        Task { await finishing.end(nil, dismissalPolicy: .immediate) }
    }
    #else
    static func start(theme: String, hue: Color, startDate: Date) {}
    static func update(photoCount: Int) {}
    static func end() {}
    #endif
}

private extension Color {
    var rgbComponents: (r: Double, g: Double, b: Double) {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
        #else
        return (0, 0, 0)
        #endif
    }
}

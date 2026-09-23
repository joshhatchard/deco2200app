//
//  WalkActivityLiveActivity.swift
//  WalkActivity
//

import ActivityKit
import WidgetKit
import SwiftUI

// Local colour constants (Palette lives in the app target, not here).
private let scrapInk = Color(.sRGB, red: 0x17 / 255, green: 0x20 / 255, blue: 0x1C / 255)
private let scrapCream = Color(.sRGB, red: 1, green: 0xF7 / 255, blue: 0xF0 / 255)

struct WalkActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkActivityAttributes.self) { context in
            // MARK: Lock Screen / banner
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("On a hunt · \(context.attributes.theme)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(scrapCream.opacity(0.7))
                        .lineLimit(1)
                    Text(context.attributes.startDate, style: .timer)
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(scrapCream)
                }
                Spacer(minLength: 8)
                VStack(spacing: 1) {
                    Text("\(context.state.photoCount)")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(scrapInk)
                    Text("photos")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(scrapInk.opacity(0.7))
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(context.attributes.hue, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(16)
            .activityBackgroundTint(scrapInk)
            .activitySystemActionForegroundColor(scrapCream)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.theme, systemImage: "figure.walk")
                        .font(.caption)
                        .foregroundStyle(context.attributes.hue)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.stack")
                        Text("\(context.state.photoCount)")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.startDate, style: .timer)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
                    .foregroundStyle(context.attributes.hue)
            } compactTrailing: {
                Text("\(context.state.photoCount)")
                    .font(.caption.weight(.bold))
            } minimal: {
                Image(systemName: "figure.walk")
                    .foregroundStyle(context.attributes.hue)
            }
            .keylineTint(context.attributes.hue)
        }
    }
}

extension WalkActivityAttributes {
    fileprivate static var preview: WalkActivityAttributes {
        WalkActivityAttributes(theme: "Testing Fair", startDate: .now,
                               hueRed: 0, hueGreen: 0.82, hueBlue: 0.45)
    }
}

extension WalkActivityAttributes.ContentState {
    fileprivate static var few: WalkActivityAttributes.ContentState { .init(photoCount: 3) }
    fileprivate static var many: WalkActivityAttributes.ContentState { .init(photoCount: 12) }
}

#Preview("Notification", as: .content, using: WalkActivityAttributes.preview) {
    WalkActivityLiveActivity()
} contentStates: {
    WalkActivityAttributes.ContentState.few
    WalkActivityAttributes.ContentState.many
}

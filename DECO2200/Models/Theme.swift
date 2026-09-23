import SwiftUI
import Foundation

/// A pickable "hunt" — either the shared daily hunt or a freestyle theme.
struct HuntTheme: Identifiable {
    let id: String
    let title: String
    let hue: Color
    let blurb: String
    let tags: [String]
}

enum Hunts {
    /// The one shared prompt everyone gets, refreshed at midnight —
    /// the Wordle-style "togetherness" mechanic from the design brief.
    static let daily = HuntTheme(id: "daily", title: "Testing Fair", hue: Palette.mint, blurb: "", tags: [])
    static let dailyPeopleOut = "3,241"

    /// Freestyle themes, chosen when the user wants their own constraint
    /// instead of today's shared one.
    static let freestyle: [HuntTheme] = [
        HuntTheme(id: "round", title: "Round things", hue: Palette.butter,
                  blurb: "Wheels, coins, manhole covers, the moon if you are lucky.",
                  tags: ["Easy"]),
        HuntTheme(id: "red", title: "Something red", hue: Palette.coral,
                  blurb: "One colour, all walk. Harder than it sounds after shot four.",
                  tags: ["Colour hunt"]),
        HuntTheme(id: "texture", title: "Textures", hue: Palette.sky,
                  blurb: "Fun and interesting textures on materials or surfaces.",
                  tags: ["Texture"])
    ]

    static func theme(for id: String) -> HuntTheme? {
        freestyle.first { $0.id == id }
    }
}

/// Countdown to the next daily-hunt refresh, formatted "4h 12m".
func countdownToMidnight(from now: Date = Date()) -> String {
    let calendar = Calendar.current
    guard let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) else {
        return "0h 00m"
    }
    let minutes = max(0, Int(midnight.timeIntervalSince(now) / 60))
    return "\(minutes / 60)h \(String(format: "%02d", minutes % 60))m"
}

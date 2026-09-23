import Foundation
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

/// Local "get moving" nudges. No server / push certificate needed — these are
/// scheduled on-device with UserNotifications, so they work on a free-signed
/// build. Banners only appear while the app is backgrounded or the phone is
/// locked (iOS suppresses them in the foreground).
enum NudgeNotifier {
    private static let identifier = "scrapmap.nudge"

    /// A little variety so it never feels like the same canned reminder.
    private static let messages: [(title: String, body: String)] = [
        ("Your chair called 🪑", "It's getting clingy. You've been sitting ages.. go find something!"),
        ("Legs on standby 🦵", "Too much sitting! The world's out there waiting to be photographed."),
        ("Psst… adventure's calling 📸", "You've been parked a while. Time to look up and hunt some shots."),
        ("Up you get, explorer 🧭", "Enough sitting for one day.. let's get moving and grab a few photos."),
        ("Move-o'clock ⏰", "Your streak misses you. Stretch those legs and go on a little hunt.")
    ]

    /// Ask once; iOS shows the allow/deny prompt automatically.
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Schedule a single nudge after `seconds`. Reuses one identifier so a new
    /// schedule replaces any still-pending one.
    static func scheduleNudge(after seconds: TimeInterval) {
        let pick = messages.randomElement() ?? messages[0]
        let content = UNMutableNotificationContent()
        content.title = pick.title
        content.body = pick.body
        content.sound = .default
        if let logo = logoAttachment() { content.attachments = [logo] }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    /// The ScrapMap logo shown as the notification's image. (The small icon on
    /// the left of a banner is always the app icon, set automatically by iOS.)
    private static func logoAttachment() -> UNNotificationAttachment? {
        #if canImport(UIKit)
        guard let image = UIImage(named: "AppLogo"), let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("scrapmap-nudge-\(UUID().uuidString).png")
        do {
            try data.write(to: url)
            return try UNNotificationAttachment(identifier: "logo", url: url)
        } catch {
            return nil
        }
        #else
        return nil
        #endif
    }

    /// Cancel the pending nudge (e.g. the user came back to the app).
    static func cancelNudge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

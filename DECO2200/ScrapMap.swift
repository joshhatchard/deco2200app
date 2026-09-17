//
//  DECO2200App.swift
//  DECO2200
//
//  Created by Christopher Do on 17/9/2026.
//

import SwiftUI
import SwiftData

@main
struct DECO2200App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: SavedCollage.self)
    }
}

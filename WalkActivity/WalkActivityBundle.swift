//
//  WalkActivityBundle.swift
//  WalkActivity
//
//  Created by Christopher Do on 18/9/2026.
//

import WidgetKit
import SwiftUI

@main
struct WalkActivityBundle: WidgetBundle {
    var body: some Widget {
        WalkActivity()
        WalkActivityControl()
        WalkActivityLiveActivity()
    }
}

import SwiftUI

/// Dispatches on `AppState.screen` — the whole loop: nudge → theme → walk
/// and shoot → shuffle → flip → share. Screens draw their own full-bleed
/// background and manage the safe area themselves via fixed top padding,
/// mirroring the prototype's simulated status-bar spacing.
struct RootView: View {
    @StateObject private var state = AppState()

    var body: some View {
        Group {
            switch state.screen {
            case .home: HomeScreen(state: state)
            case .nudge: NudgeScreen(state: state)
            case .theme: ThemeScreen(state: state)
            case .breakScreen: BreakScreen(state: state)
            case .gallery: GalleryScreen(state: state)
            case .congrats: CongratsScreen(state: state)
            case .share: ShareScreen(state: state)
            case .profile: ProfileScreen(state: state)
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.98)),
            removal: .opacity
        ))
        .animation(.easeOut(duration: 0.3), value: state.screen)
        .ignoresSafeArea(.container, edges: .all)
        .preferredColorScheme(.light)
        .onAppear { state.syncTimer() }
        .onChange(of: state.screen) { _ in state.syncTimer() }
    }
}

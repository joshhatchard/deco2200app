import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BreakScreen: View {
    @ObservedObject var state: AppState
    @State private var showChangeHunt = false
    #if canImport(UIKit)
    @StateObject private var camera = CameraController()
    #endif

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button { showChangeHunt = true } label: {
                    Text("‹").font(.mono(15))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white))
                        .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
                        .foregroundStyle(Palette.ink)
                }
                .buttonStyle(.plain)
                Text(state.formattedElapsed)
                    .font(.mono(16, weight: .medium))
                    .foregroundStyle(Palette.cream)
                    .padding(.horizontal, 15).padding(.vertical, 9)
                    .background(Capsule().fill(Palette.ink))
                Spacer()
                MonoLabel(text: "\(state.photos.count) photos", size: 12, color: Palette.ink, tracking: 0.4)
                    .padding(.horizontal, 15).padding(.vertical, 9)
                    .background(Capsule().fill(.white))
                    .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ZStack {
                        cameraBackground
                        #if canImport(UIKit)
                        if camera.isAuthorized {
                            Button { camera.flip() } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Palette.ink)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(.white.opacity(0.9)))
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(12)
                        }
                        #endif
                        VStack(alignment: .leading, spacing: 2) {
                            MonoLabel(text: state.huntKind, size: 9, color: Color(hex: 0x6B5A17), tracking: 1.4)
                            Text(state.themeTitle)
                                .font(.display(24))
                                .foregroundStyle(Palette.ink)
                                .lineLimit(2)
                        }
                        .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.butter))
                        .rotationEffect(.degrees(1.4))
                        .shadow(color: Palette.ink.opacity(0.07), radius: 0, x: 3, y: 3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .frame(maxHeight: .infinity)

                    Text("Shoot as many as you like")
                        .font(.display(15, weight: .bold))
                        .foregroundStyle(Palette.mutedInk)
                        .padding(.top, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 20, trailing: 12))
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white))
                .hardShadow(Palette.ink.opacity(0.05), x: 4, y: 4)
                .rotationEffect(.degrees(-1.2))
                .frame(maxHeight: .infinity)

                HStack(spacing: 14) {
                    Button { state.go(.gallery) } label: { stackThumbnail }
                        .buttonStyle(.plain)
                    Text(state.photos.isEmpty ? "Tap the big button to start your roll" : "Tap the pile to review and bin any duds")
                        .font(.body(12, weight: .bold))
                        .foregroundStyle(Palette.ink.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        #if canImport(UIKit)
                        Task {
                            let data = await camera.capturePhoto()
                            state.capture(imageData: data)
                        }
                        #else
                        state.capture()
                        #endif
                    } label: {
                        Circle().fill(.white)
                            .frame(width: 82, height: 82)
                            .overlay(Circle().fill(Palette.green).frame(width: 62, height: 62))
                            .shadow(color: Palette.ink.opacity(0.06), radius: 0, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 18)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)

            Button {
                state.finishShooting()
            } label: {
                Text("Done walking")
                    .font(.display(19, weight: .bold))
                    .foregroundStyle(Palette.cream)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(state.currentHue)
        .confirmationDialog("Change your hunt?", isPresented: $showChangeHunt, titleVisibility: .visible) {
            Button("Change hunt", role: .destructive) { state.go(.theme) }
            Button("Keep walking", role: .cancel) { }
        } message: {
            Text("This ends your current walk and discards the photos you've taken.")
        }
        #if canImport(UIKit)
        .task { await camera.start() }
        .onDisappear { camera.stop() }
        #endif
    }

    @ViewBuilder private var cameraBackground: some View {
        #if canImport(UIKit)
        if camera.isAuthorized {
            CameraPreview(session: camera.session)
        } else {
            placeholderCamera
        }
        #else
        placeholderCamera
        #endif
    }

    private var placeholderCamera: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Palette.ink.opacity(0.86))
            MonoLabel(text: "Live camera", size: 10, color: Palette.cream.opacity(0.5), tracking: 1.6)
        }
    }

    private var stackThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.white)
                .rotationEffect(.degrees(-10))
                .hardShadow(Palette.ink.opacity(0.06), x: 2, y: 2)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(state.photos.isEmpty ? Palette.ink.opacity(0.14) : state.currentHue.mixed(with: Palette.cream, percent: 82))
                .overlay {
                    #if canImport(UIKit)
                    if let data = state.photos.last?.imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui).resizable().scaledToFill()
                    }
                    #endif
                }
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                .padding(6)
                .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous).stroke(.white, lineWidth: 6))
                .rotationEffect(.degrees(5))
                .hardShadow(Palette.ink.opacity(0.06), x: 2, y: 2)
        }
        .frame(width: 64, height: 64)
    }
}

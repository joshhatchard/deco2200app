import SwiftUI

/// Optional caption + voice memo step, shown right after "Use this one" and
/// before the congrats card. Everything here is optional — Continue works blank.
struct PostDetailsScreen: View {
    @ObservedObject var state: AppState
    @FocusState private var captionFocused: Bool
    @StateObject private var recorder = VoiceMemoRecorder()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { state.go(.gallery) } label: {
                    Text("‹").font(.mono(15))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white))
                        .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
                        .foregroundStyle(Palette.ink)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 56)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Anything to say?")
                        .font(.display(40))
                        .foregroundStyle(Palette.ink)
                    Text("Add a caption or a voice memo")
                        .font(.body(14, weight: .semibold))
                        .foregroundStyle(Palette.mutedInk)
                        .padding(.top, 6)

                    HStack(spacing: 8) {
                        Text("Caption").font(.display(18, weight: .bold))
                        MonoLabel(text: "optional", size: 9, color: Palette.mutedInk, tracking: 1.2)
                    }
                    .padding(.top, 26).padding(.bottom, 10)

                    TextField("Say something about your walk…", text: $state.caption, axis: .vertical)
                        .font(.body(14, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .focused($captionFocused)
                        .lineLimit(2...4)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Palette.ink.opacity(0.12), lineWidth: 2))

                    HStack(spacing: 8) {
                        Text("Voice memo").font(.display(18, weight: .bold))
                        MonoLabel(text: "optional", size: 9, color: Palette.mutedInk, tracking: 1.2)
                    }
                    .padding(.top, 26).padding(.bottom, 10)

                    voiceMemoSection
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
            .scrollDismissesKeyboard(.interactively)

            Button { state.go(.congrats) } label: {
                Text("Continue")
                    .font(.display(21, weight: .bold))
                    .foregroundStyle(Palette.cream)
                    .frame(maxWidth: .infinity).frame(height: 60)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.shareBg)
        .overlay {
            // Tap anywhere to dismiss the keyboard — only active while the
            // caption is focused, so it never steals the field's own tap.
            if captionFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { captionFocused = false }
            }
        }
    }

    @ViewBuilder private var voiceMemoSection: some View {
        if let data = state.voiceMemo {
            HStack(spacing: 12) {
                VoiceMemoPlayButton(data: data)
                Spacer(minLength: 0)
                Button { state.voiceMemo = nil } label: {
                    MonoLabel(text: "Delete", size: 10, color: Palette.coral, tracking: 1)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                }
                .buttonStyle(.plain)
            }
        } else if recorder.isRecording {
            Button { state.voiceMemo = recorder.stop() } label: {
                HStack(spacing: 10) {
                    Circle().fill(Palette.coral).frame(width: 12, height: 12)
                    if let started = recorder.startedAt {
                        Text(started, style: .timer)
                            .font(.mono(16, weight: .medium)).foregroundStyle(Palette.ink)
                    }
                    Spacer(minLength: 0)
                    Text("Tap to stop").font(.body(12.5, weight: .bold)).foregroundStyle(Palette.ink.opacity(0.7))
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.coral.opacity(0.12)))
            }
            .buttonStyle(.plain)
        } else {
            Button { recorder.start() } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mic.fill").font(.system(size: 16, weight: .bold))
                    Text("Record a voice memo").font(.body(13.5, weight: .bold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Palette.ink)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.white))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Palette.ink.opacity(0.12), lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }
}

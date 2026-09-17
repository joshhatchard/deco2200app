import SwiftUI

struct ThemeScreen: View {
    @ObservedObject var state: AppState
    @FocusState private var customFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { state.go(.home) } label: {
                    Text("‹").font(.mono(15))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white))
                        .hardShadow(Palette.ink.opacity(0.05), x: 2, y: 2)
                        .foregroundStyle(Palette.ink)
                }
                .buttonStyle(.plain)
                Spacer()
                MonoLabel(text: "Pick your hunt", size: 10, tracking: 1.4)
            }
            .padding(.horizontal, 22)
            .padding(.top, 56)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    dailyCard
                    sectionRule.padding(.top, 22)
                    VStack(spacing: 12) {
                        ForEach(Hunts.freestyle) { theme in
                            freestyleCard(theme)
                        }
                        customCard
                    }
                    .padding(.top, 14)
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)

            Button {
                state.startBreak()
            } label: {
                Text("Start · \(state.themeTitle)")
                    .font(.display(22, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(Capsule().fill(state.currentHue))
                    .shadow(color: Palette.ink.opacity(0.07), radius: 0, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.themeBg)
        .overlay {
            // Only intercept taps while typing, so it never steals the
            // TextField's own focus tap — tap anywhere to dismiss.
            if customFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { customFocused = false }
            }
        }
    }

    private var dailyCard: some View {
        let selected = state.isDailyTheme
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                MonoLabel(text: "Today's hunt · everyone", size: 9.5, color: Palette.ink, tracking: 1.6)
                Spacer()
                Circle()
                    .fill(selected ? Palette.ink : Color.clear)
                    .overlay(Circle().strokeBorder(selected ? Color.clear : Palette.ink.opacity(0.25), lineWidth: 2.5))
                    .frame(width: 26, height: 26)
            }
            Text(Hunts.daily.title)
                .font(.display(30))
                .foregroundStyle(Palette.ink)
                .padding(.top, 6)
            HStack(spacing: 8) {
                MonoLabel(text: "\(Hunts.dailyPeopleOut) out today", size: 10.5, color: Palette.ink, tracking: 0.4)
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(Capsule().fill(Palette.ink.opacity(0.14)))
                MonoLabel(text: "Gone in \(countdownToMidnight())", size: 10.5, color: Palette.cream, tracking: 0.4)
                    .padding(.horizontal, 11).padding(.vertical, 6)
                    .background(Capsule().fill(Palette.ink))
            }
            .padding(.top, 14)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(selected ? Hunts.daily.hue : .white))
        .shadow(color: Palette.ink.opacity(selected ? 0.07 : 0.04), radius: 0, x: selected ? 4 : 3, y: selected ? 4 : 3)
        .contentShape(Rectangle())
        .onTapGesture { state.pickDaily() }
    }

    private var sectionRule: some View {
        HStack(spacing: 9) {
            Text("Or freestyle it").font(.display(19, weight: .bold))
            Rectangle().fill(Palette.ink.opacity(0.12)).frame(height: 3).clipShape(Capsule())
        }
    }

    private func freestyleCard(_ theme: HuntTheme) -> some View {
        let selected = state.themeId == theme.id
        return HStack(alignment: .center, spacing: 14) {
            BlobFace(size: 54, color: selected ? .white.opacity(0.62) : theme.hue,
                     showSmile: true, wobble: selected)
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.title).font(.display(24)).foregroundStyle(Palette.ink)
                Text(theme.blurb).font(.body(13, weight: .semibold)).foregroundStyle(Palette.ink.opacity(0.78))
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(selected ? theme.hue : .white))
        .shadow(color: Palette.ink.opacity(selected ? 0.07 : 0.04), radius: 0, x: selected ? 4 : 3, y: selected ? 4 : 3)
        .rotationEffect(.degrees(selected ? -1.6 : 0))
        .scaleEffect(selected ? 1.02 : 1)
        .contentShape(Rectangle())
        .onTapGesture { state.selectTheme(theme.id) }
    }

    private var customCard: some View {
        let selected = state.isCustomTheme
        return TextField("or write your own…", text: $state.customTheme)
            .font(.display(22, weight: .bold))
            .foregroundStyle(Palette.ink)
            .focused($customFocused)
            .onChange(of: customFocused) { focused in
                if focused { state.selectCustom() }
            }
            .onChange(of: state.customTheme) { _ in state.selectCustom() }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(selected ? Palette.lilac : .white))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(selected ? Color.clear : Palette.ink.opacity(0.12), lineWidth: 2.5)
            )
            .shadow(color: selected ? Palette.ink.opacity(0.07) : Color.clear, radius: 0, x: selected ? 3 : 0, y: selected ? 3 : 0)
    }
}

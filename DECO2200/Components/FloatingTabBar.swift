import SwiftUI

enum TabKind: Equatable { case feed, profile }

/// The floating dark pill tab bar with a raised coral… no — green "+" that
/// sits on both Home and Profile.
struct FloatingTabBar: View {
    var active: TabKind
    var surroundingBg: Color
    var onFeed: () -> Void
    var onCreate: () -> Void
    var onProfile: () -> Void

    var body: some View {
        HStack {
            tab(kind: .feed, action: onFeed)
            Spacer()
            createButton
            Spacer()
            tab(kind: .profile, action: onProfile)
        }
        .padding(.horizontal, 26)
        .frame(height: 62)
        .background(
            NotchedBar(cornerRadius: 31, notchWidth: 96, notchDepth: 24)
                .fill(Palette.ink)
                .shadow(color: Palette.ink.opacity(0.10), radius: 20, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }

    private func tab(kind: TabKind, action: @escaping () -> Void) -> some View {
        let isActive = kind == active
        let label = kind == .feed ? "Home" : "You"
        let color = isActive ? Palette.cream : Palette.cream.opacity(0.6)
        return Button(action: action) {
            VStack(spacing: 4) {
                icon(kind: kind, isActive: isActive, color: color)
                    .frame(width: 20, height: 20)
                MonoLabel(text: label, size: 9, color: color, tracking: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func icon(kind: TabKind, isActive: Bool, color: Color) -> some View {
        let name: String
        switch kind {
        case .feed: name = isActive ? "house.fill" : "house"
        case .profile: name = isActive ? "person.crop.circle.fill" : "person.crop.circle"
        }
        return Image(systemName: name)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(color)
    }

    private var createButton: some View {
        Button(action: onCreate) {
            Text("+")
                .font(.display(30))
                .foregroundStyle(Palette.ink)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Palette.green))
                .overlay(Circle().strokeBorder(surroundingBg, lineWidth: 5))
                .shadow(color: Palette.green.opacity(0.15), radius: 9, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .offset(y: -26)
    }
}

/// A rounded bar with a smooth concave scoop at the top-centre, so the raised
/// create button nestles into a notch rather than sitting on a flat pill.
struct NotchedBar: Shape {
    var cornerRadius: CGFloat = 31
    var notchWidth: CGFloat = 96
    var notchDepth: CGFloat = 24

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(cornerRadius, rect.height / 2)
        let top = rect.minY
        let cx = rect.midX
        let halfW = notchWidth / 2
        let depth = notchDepth

        path.move(to: CGPoint(x: rect.minX, y: top + r))
        path.addArc(center: CGPoint(x: rect.minX + r, y: top + r), radius: r,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        // top edge up to the left lip of the notch
        path.addLine(to: CGPoint(x: cx - halfW, y: top))
        // smooth valley down to the centre and back up (two mirrored cubics)
        path.addCurve(
            to: CGPoint(x: cx, y: top + depth),
            control1: CGPoint(x: cx - halfW * 0.5, y: top),
            control2: CGPoint(x: cx - halfW * 0.42, y: top + depth)
        )
        path.addCurve(
            to: CGPoint(x: cx + halfW, y: top),
            control1: CGPoint(x: cx + halfW * 0.42, y: top + depth),
            control2: CGPoint(x: cx + halfW * 0.5, y: top)
        )
        // remaining top edge to the top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - r, y: top))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: top + r), radius: r,
                    startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r), radius: r,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Palette.homeBg
        FloatingTabBar(active: .feed, surroundingBg: Palette.homeBg,
                       onFeed: {}, onCreate: {}, onProfile: {})
    }
    .frame(height: 220)
}

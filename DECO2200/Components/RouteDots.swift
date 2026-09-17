import SwiftUI

/// Route maps are abstract dot fields, not real cartography — a stand-in
/// until GPS data exists to draw a real polyline.
struct RouteDots: View {
    var color: Color
    var dotCount: Int = 3

    private let positions3: [(CGFloat, CGFloat)] = [(0.20, 0.70), (0.46, 0.32), (0.72, 0.68)]
    private let positions4: [(CGFloat, CGFloat)] = [(0.18, 0.70), (0.44, 0.30), (0.68, 0.66), (0.88, 0.34)]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<dotCount, id: \.self) { i in
                let p = (dotCount >= 4 ? positions4 : positions3)[i % (dotCount >= 4 ? positions4.count : positions3.count)]
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .position(x: geo.size.width * p.0, y: geo.size.height * p.1)
            }
        }
    }
}

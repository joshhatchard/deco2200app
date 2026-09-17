import Foundation

/// One row of a collage: how many photo indices it holds, and what
/// fraction of the frame's total height it should claim.
struct CollageRow: Identifiable {
    let id = UUID()
    let indices: [Int]
    let grow: Double
}

/// Splits `n` photos into rows that always fill the frame exactly, at any
/// count — a direct port of the prototype's `collageRows()`. Rows with
/// fewer photos grow taller, which is what makes the arrangement look
/// composed rather than just tiled. `seed` nudges photos between adjacent
/// rows so the same count reshuffles differently each time (the "shake").
func collageRows(count n: Int, seed: Int) -> [CollageRow] {
    guard n > 0 else { return [] }
    let rows = max(1, min(6, Int((Double(n) * 0.85).squareRoot().rounded())))
    let base = n / rows
    let extra = n % rows
    var counts = (0..<rows).map { r in base + (r < extra ? 1 : 0) }

    for r in 0..<(rows - 1) where (seed + r) % 3 == 0 {
        if counts[r] > 1 && counts[r + 1] < 6 {
            counts[r] -= 1
            counts[r + 1] += 1
        }
    }

    let live = counts.filter { $0 > 0 }
    let total = live.reduce(0.0) { $0 + 1.0 / Double($1) }
    var k = 0
    return live.map { c in
        let idx = (0..<c).map { _ -> Int in defer { k += 1 }; return k }
        return CollageRow(indices: idx, grow: (1.0 / Double(c)) / total)
    }
}

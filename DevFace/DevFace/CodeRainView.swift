import SwiftUI

/// Subtle falling-code background, drawn in a single Canvas.
/// Everything is derived from `date`, so it is stateless and cheap to redraw.
struct CodeRainView: View {
    let date: Date
    let color: Color

    private static let glyphs = Array("01{}[]()<>=;:/*+-&|!?$#@λ→")
    private let cell: CGFloat = 11
    private let trail = 9

    var body: some View {
        Canvas { context, size in
            let t = date.timeIntervalSinceReferenceDate
            let columns = Int(size.width / cell)
            let rows = Int(size.height / cell) + trail
            let font = Font.system(size: 9, weight: .medium, design: .monospaced)

            // Resolve each glyph once per frame instead of once per cell.
            let resolved = Self.glyphs.map {
                context.resolve(Text(String($0)).font(font).foregroundStyle(color))
            }

            for col in 0..<columns {
                // Only some columns are active, so the rain stays readable behind the clock.
                guard noise(col, 1) > 0.35 else { continue }
                let speed = 3 + noise(col, 2) * 6            // rows per second
                let offset = noise(col, 3) * Double(rows)
                let head = Int((t * speed + offset).truncatingRemainder(dividingBy: Double(rows)))

                for i in 0..<trail {
                    let row = head - i
                    guard row >= 0 else { continue }
                    let y = CGFloat(row) * cell
                    guard y < size.height else { continue }

                    // Glyphs flicker at a per-cell rate.
                    let tick = Int(t * (2 + noise(col, row) * 4))
                    let glyph = resolved[Int(noise(tick, col * 31 + row) * Double(resolved.count))]

                    var cellContext = context
                    cellContext.opacity = i == 0 ? 1 : 0.75 * (1 - Double(i) / Double(trail))
                    cellContext.draw(glyph, at: CGPoint(x: CGFloat(col) * cell + cell / 2, y: y))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

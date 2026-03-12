import SwiftUI

/// Renders an `ItemDescriptor` (JSON shape description) as a SwiftUI view.
public struct DynamicLayerView: View {
    let descriptor: ItemDescriptor
    let palette: ColourPalette
    let skinTone: SkinTone

    public init(descriptor: ItemDescriptor, palette: ColourPalette, skinTone: SkinTone = .medium) {
        self.descriptor = descriptor
        self.palette = palette
        self.skinTone = skinTone
    }

    public var body: some View {
        ZStack {
            ForEach(Array(descriptor.shapes.enumerated()), id: \.offset) { _, shape in
                DynamicShapeView(shape: shape, palette: palette, skinTone: skinTone)
            }
        }
        .frame(width: 150, height: 275)
    }
}

// MARK: - Single Shape View

/// Renders one `ShapeDescriptor` with its modifiers and overlays.
/// Broken out as a separate struct to keep type-checker complexity low.
struct DynamicShapeView: View {
    let shape: ShapeDescriptor
    let palette: ColourPalette
    let skinTone: SkinTone

    var body: some View {
        baseShape
            .opacity(shape.common.opacity)
            .rotationEffect(
                .degrees(shape.common.rotation),
                anchor: shape.common.rotationAnchor.unitPoint
            )
            .offset(x: shape.common.offsetX, y: shape.common.offsetY)
    }

    @ViewBuilder
    private var baseShape: some View {
        switch shape {
        case .roundedRectangle(let d):
            RoundedRectangle(cornerRadius: d.cornerRadius)
                .fill(resolveColor(d.fill))
                .frame(width: d.width, height: d.height)
                .overlay(content: { overlays })

        case .circle(let d):
            Circle()
                .fill(resolveColor(d.fill))
                .frame(width: d.diameter, height: d.diameter)
                .overlay(content: { overlays })

        case .ellipse(let d):
            Ellipse()
                .fill(resolveColor(d.fill))
                .frame(width: d.width, height: d.height)
                .overlay(content: { overlays })

        case .taperedRect(let d):
            TaperedRect(topWidth: d.topWidth, bottomWidth: d.bottomWidth, cornerRadius: d.cornerRadius)
                .fill(resolveColor(d.fill))
                .frame(width: d.width, height: d.height)
                .overlay(content: { overlays })

        case .quadCurve(let d):
            Path { path in
                path.move(to: CGPoint(x: d.startX, y: d.startY))
                path.addQuadCurve(
                    to: CGPoint(x: d.endX, y: d.endY),
                    control: CGPoint(x: d.controlX, y: d.controlY)
                )
            }
            .stroke(resolveColor(d.strokeColor), lineWidth: d.lineWidth)
            .frame(width: 150, height: 275)
        }
    }

    @ViewBuilder
    private var overlays: some View {
        let items = shape.common.overlays
        if !items.isEmpty {
            ZStack {
                ForEach(Array(items.enumerated()), id: \.offset) { _, overlay in
                    DynamicShapeView(shape: overlay, palette: palette, skinTone: skinTone)
                }
            }
        }
    }

    private func resolveColor(_ fill: FillColor) -> Color {
        switch fill {
        case .palette(let name):
            switch name {
            case "primary": return palette.primary
            case "secondary": return palette.secondary
            case "accent": return palette.accent
            case "skin": return skinTone.color
            default: return Color.gray
            }
        case .hex(let hex, let opacity):
            let sanitized = hex.replacingOccurrences(of: "#", with: "")
            var rgb: UInt64 = 0
            Scanner(string: sanitized).scanHexInt64(&rgb)
            return Color(
                red: Double((rgb >> 16) & 0xFF) / 255.0,
                green: Double((rgb >> 8) & 0xFF) / 255.0,
                blue: Double(rgb & 0xFF) / 255.0,
                opacity: opacity
            )
        }
    }
}

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

// MARK: - Preview

/// JSON matching the default TopLayer: TaperedRect torso only
private let previewTopJSON = """
{
    "schemaVersion": 1,
    "itemId": "preview-default-top",
    "layerOrder": "top",
    "shapes": [
        {
            "type": "taperedRect",
            "topWidth": 54, "bottomWidth": 65, "cornerRadius": 9,
            "width": 65, "height": 57,
            "fill": { "hex": "#DDDDDD" },
            "offsetY": -8
        }
    ]
}
"""

/// JSON matching the default BottomLayer: two leg rects (rotated) + waistband
private let previewBottomJSON = """
{
    "schemaVersion": 1,
    "itemId": "preview-default-bottom",
    "layerOrder": "bottom",
    "shapes": [
        {
            "type": "roundedRectangle",
            "width": 30, "height": 28, "cornerRadius": 4,
            "fill": { "hex": "#8A8A8A" },
            "rotation": 8.5,
            "offsetX": -16, "offsetY": 42
        },
        {
            "type": "roundedRectangle",
            "width": 30, "height": 28, "cornerRadius": 4,
            "fill": { "hex": "#8A8A8A" },
            "rotation": -8.5,
            "offsetX": 16, "offsetY": 42
        },
        {
            "type": "roundedRectangle",
            "width": 62, "height": 12, "cornerRadius": 4,
            "fill": { "hex": "#8A8A8A" },
            "offsetY": 28
        }
    ]
}
"""

struct DynamicLayerView_Previews: PreviewProvider {
    static let palette = ColourPalette(
        primary: ColourPalette.from(hex: "#3B2F2F"),
        secondary: ColourPalette.from(hex: "#D6E4F0"),
        accent: ColourPalette.from(hex: "#5B9BD5")
    )

    static var topDescriptor: ItemDescriptor {
        try! JSONDecoder().decode(ItemDescriptor.self, from: Data(previewTopJSON.utf8))
    }

    static var bottomDescriptor: ItemDescriptor {
        try! JSONDecoder().decode(ItemDescriptor.self, from: Data(previewBottomJSON.utf8))
    }

    static var previews: some View {
        VStack(spacing: 24) {
            Text("Left: Base Avatar  |  Right: JSON Renderer")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                // Base avatar (built-in layers)
                VStack {
                    AvatarCompositorView(
                        configuration: .defaultConfiguration,
                        palette: palette
                    )
                    Text("Built-in")
                        .font(.caption)
                }

                // JSON-rendered top + bottom overlaid on the base body
                VStack {
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(palette.secondary)
                            .frame(width: 150, height: 275)

                        Group {
                            // Base body (skin)
                            BodyLayer(skinTone: .medium)
                            // JSON-rendered bottom
                            DynamicLayerView(
                                descriptor: bottomDescriptor,
                                palette: palette,
                                skinTone: .medium
                            )
                            // JSON-rendered top
                            DynamicLayerView(
                                descriptor: topDescriptor,
                                palette: palette,
                                skinTone: .medium
                            )
                            // Head + face on top
                            HeadLayer(skinTone: .medium)
                            FaceLayer()
                        }
                        .offset(y: 17)
                    }
                    .frame(width: 150, height: 275)
                    .clipped()

                    Text("JSON Rendered")
                        .font(.caption)
                }
            }
        }
        .padding()
        .previewDisplayName("DynamicLayerView Comparison")
    }
}

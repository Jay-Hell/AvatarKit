import SwiftUI

// MARK: - Sleeve Style

public enum SleeveStyle: String, CaseIterable {
    case short     // covers upper arm (~30pt)
    case long      // covers full arm (~59pt)

    /// Sleeve height with +6pt body coverage margin on width, +4pt on height.
    var height: CGFloat {
        switch self {
        case .short: return 30
        case .long:  return 59   // body arm 55 + 4
        }
    }

    /// Sleeve offsetY so the top aligns with the shoulder at y: -34.
    /// Formula: -34 + (height / 2)
    var offsetY: CGFloat {
        -34 + height / 2
    }
}

// MARK: - Bottom Style

public enum BottomStyle: String, CaseIterable {
    case shortTrousers
    case longTrousers
    case shortSkirt
    case longSkirt

    var isTrousers: Bool {
        self == .shortTrousers || self == .longTrousers
    }

    var isSkirt: Bool {
        self == .shortSkirt || self == .longSkirt
    }

    /// Leg/skirt shape height. All variants align their top edge at y: 28 (waist).
    var shapeHeight: CGFloat {
        switch self {
        case .shortTrousers, .shortSkirt: return 28
        case .longTrousers, .longSkirt:   return 48
        }
    }

    /// Centre offsetY so the top edge sits at y: 28 (waist level).
    /// Formula: 28 + (shapeHeight / 2)
    var offsetY: CGFloat {
        28 + shapeHeight / 2
    }
}

// MARK: - Top Item Template

/// Minimum coverage shapes for the "top" category.
/// Derived from BodyLayer: torso +6w/+4h, arms +6w/+4h, same rotations.
/// Sleeve length is parameterised via ``SleeveStyle``.
public struct TopItemTemplate: View {
    let palette: ColourPalette
    let sleeveStyle: SleeveStyle

    public init(palette: ColourPalette, sleeveStyle: SleeveStyle = .short) {
        self.palette = palette
        self.sleeveStyle = sleeveStyle
    }

    public var body: some View {
        ZStack {
            // Left arm — body: 20×55, template: 26×height, rotation 30° anchor .top
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.primary)
                .frame(width: 26, height: sleeveStyle.height)
                .rotationEffect(.degrees(30), anchor: .top)
                .offset(x: -22, y: sleeveStyle.offsetY)

            // Right arm — body: 20×55, template: 26×height, rotation -30° anchor .top
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.primary)
                .frame(width: 26, height: sleeveStyle.height)
                .rotationEffect(.degrees(-30), anchor: .top)
                .offset(x: 22, y: sleeveStyle.offsetY)

            // Torso — body: topWidth 54, bottomWidth 65, 65×57
            //         template: topWidth 60, bottomWidth 71, 71×61, offset y:-8
            TaperedRect(topWidth: 60, bottomWidth: 71, cornerRadius: 9)
                .fill(palette.primary)
                .frame(width: 71, height: 61)
                .offset(y: -8)
        }
        .offset(y: 17)
        .frame(width: 150, height: 275)
    }
}

// MARK: - Bottom Item Template

/// Minimum coverage shapes for the "bottom" category.
/// Derived from BodyLayer: legs +6w/+4h, same rotations.
/// Style is parameterised via ``BottomStyle`` — trousers use separate leg
/// shapes; skirts use a single flared TaperedRect.
public struct BottomItemTemplate: View {
    let palette: ColourPalette
    let style: BottomStyle

    public init(palette: ColourPalette, style: BottomStyle = .shortTrousers) {
        self.palette = palette
        self.style = style
    }

    public var body: some View {
        ZStack {
            if style.isTrousers {
                // Left leg — body: 28×37, template: 34×height, rotation 8.5°
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.primary)
                    .frame(width: 34, height: style.shapeHeight)
                    .rotationEffect(.degrees(8.5))
                    .offset(x: -17, y: style.offsetY)

                // Right leg — body: 28×37, template: 34×height, rotation -8.5°
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.primary)
                    .frame(width: 34, height: style.shapeHeight)
                    .rotationEffect(.degrees(-8.5))
                    .offset(x: 17, y: style.offsetY)
            } else {
                // Skirt — single flared TaperedRect covering both legs
                TaperedRect(
                    topWidth: 68,
                    bottomWidth: style == .shortSkirt ? 80 : 90,
                    cornerRadius: 9
                )
                .fill(palette.primary)
                .frame(
                    width: style == .shortSkirt ? 80 : 90,
                    height: style.shapeHeight
                )
                .offset(y: style.offsetY)
            }

            // Waistband — width: 65+6=71, height: 12, offset y: 26
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.primary)
                .frame(width: 71, height: 12)
                .offset(y: 26)
        }
        .offset(y: 17)
        .frame(width: 150, height: 275)
    }
}

// MARK: - Shoes Item Template

/// Minimum coverage shapes for the "shoes" category.
/// Derived from BodyLayer: feet +4w/+4h, same offsets.
public struct ShoesItemTemplate: View {
    let palette: ColourPalette

    public init(palette: ColourPalette) {
        self.palette = palette
    }

    public var body: some View {
        ZStack {
            // Left foot — body: 34×14, template: 38×18, offset x:-23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.primary)
                .frame(width: 38, height: 18)
                .offset(x: -23, y: 75)

            // Right foot — body: 34×14, template: 38×18, offset x:23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.primary)
                .frame(width: 38, height: 18)
                .offset(x: 23, y: 75)
        }
        .offset(y: 17)
        .frame(width: 150, height: 275)
    }
}

// MARK: - Template Code for Generation Prompt

public enum ItemTemplates {

    /// Returns a SwiftUI code string describing the minimum required shapes
    /// for the given clothing category and variant. Intended to be embedded in
    /// the generation prompt so the model knows the structural base.
    ///
    /// - Parameters:
    ///   - category: The item category ("top", "bottom", "shoes").
    ///   - variant: Style variant. For "top": "shortSleeve" or "longSleeve".
    ///     For "bottom": "shortTrousers", "longTrousers", "shortSkirt", "longSkirt".
    ///     Ignored for other categories. Defaults to short variant.
    public static func templateCode(for category: String, variant: String = "") -> String {
        switch category {
        case "top":
            return variant == "longSleeve" ? topLongSleeveCode : topShortSleeveCode
        case "bottom":
            switch variant {
            case "longTrousers": return bottomLongTrousersCode
            case "shortSkirt":   return bottomShortSkirtCode
            case "longSkirt":    return bottomLongSkirtCode
            default:             return bottomShortTrousersCode
            }
        case "shoes":
            return shoesCode
        default:
            return ""
        }
    }

    // MARK: Top — short sleeve

    private static let topShortSleeveCode = """
    // --- MINIMUM TEMPLATE SHAPES (top — short sleeve) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Torso (covers body torso — TaperedRect)
    TaperedRect(topWidth: 60, bottomWidth: 71, cornerRadius: 9)
        .fill(palette.primary)
        .frame(width: 71, height: 61)
        .offset(y: -8)

    // Left sleeve (covers upper body left arm — rotated from shoulder)
    // Shoulder at y: -34. offsetY = -34 + (30 / 2) = -19
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 26, height: 30)
        .rotationEffect(.degrees(30), anchor: .top)
        .offset(x: -22, y: -19)

    // Right sleeve (covers upper body right arm — rotated from shoulder)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 26, height: 30)
        .rotationEffect(.degrees(-30), anchor: .top)
        .offset(x: 22, y: -19)
    """

    // MARK: Top — long sleeve

    private static let topLongSleeveCode = """
    // --- MINIMUM TEMPLATE SHAPES (top — long sleeve) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Torso (covers body torso — TaperedRect)
    TaperedRect(topWidth: 60, bottomWidth: 71, cornerRadius: 9)
        .fill(palette.primary)
        .frame(width: 71, height: 61)
        .offset(y: -8)

    // Left sleeve (covers full body left arm — rotated from shoulder)
    // Shoulder at y: -34. offsetY = -34 + (59 / 2) = -4.5
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 26, height: 59)
        .rotationEffect(.degrees(30), anchor: .top)
        .offset(x: -22, y: -4.5)

    // Right sleeve (covers full body right arm — rotated from shoulder)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 26, height: 59)
        .rotationEffect(.degrees(-30), anchor: .top)
        .offset(x: 22, y: -4.5)
    """

    // MARK: Bottom — short trousers

    private static let bottomShortTrousersCode = """
    // --- MINIMUM TEMPLATE SHAPES (bottom — short trousers) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Left leg (covers upper body left leg)
    // Top edge at y: 28 (waist). offsetY = 28 + (28 / 2) = 42
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 34, height: 28)
        .rotationEffect(.degrees(8.5))
        .offset(x: -17, y: 42)

    // Right leg (covers upper body right leg)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 34, height: 28)
        .rotationEffect(.degrees(-8.5))
        .offset(x: 17, y: 42)

    // Waistband (sits above legs, spans full width)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 71, height: 12)
        .offset(y: 26)
    """

    // MARK: Bottom — long trousers

    private static let bottomLongTrousersCode = """
    // --- MINIMUM TEMPLATE SHAPES (bottom — long trousers) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Left leg (covers full body left leg down to ankle)
    // Top edge at y: 28 (waist). offsetY = 28 + (48 / 2) = 52
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 34, height: 48)
        .rotationEffect(.degrees(8.5))
        .offset(x: -17, y: 52)

    // Right leg (covers full body right leg down to ankle)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 34, height: 48)
        .rotationEffect(.degrees(-8.5))
        .offset(x: 17, y: 52)

    // Waistband (sits above legs, spans full width)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 71, height: 12)
        .offset(y: 26)
    """

    // MARK: Bottom — short skirt

    private static let bottomShortSkirtCode = """
    // --- MINIMUM TEMPLATE SHAPES (bottom — short skirt) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Skirt body (single flared shape covering both legs)
    // topWidth matches waist, bottomWidth flares out past legs.
    // Top edge at y: 28. offsetY = 28 + (28 / 2) = 42
    TaperedRect(topWidth: 68, bottomWidth: 80, cornerRadius: 9)
        .fill(palette.primary)
        .frame(width: 80, height: 28)
        .offset(y: 42)

    // Waistband (sits above skirt, spans full width)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 71, height: 12)
        .offset(y: 26)
    """

    // MARK: Bottom — long skirt

    private static let bottomLongSkirtCode = """
    // --- MINIMUM TEMPLATE SHAPES (bottom — long skirt) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Skirt body (single flared shape covering both legs to ankle)
    // topWidth matches waist, bottomWidth flares wide past feet.
    // Top edge at y: 28. offsetY = 28 + (48 / 2) = 52
    TaperedRect(topWidth: 68, bottomWidth: 90, cornerRadius: 9)
        .fill(palette.primary)
        .frame(width: 90, height: 48)
        .offset(y: 52)

    // Waistband (sits above skirt, spans full width)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 71, height: 12)
        .offset(y: 26)
    """

    // MARK: Shoes

    private static let shoesCode = """
    // --- MINIMUM TEMPLATE SHAPES (shoes) ---
    // Your item MUST include shapes at least this large at these exact positions.
    // You may increase sizes, add detail shapes, and change fills,
    // but do NOT shrink or reposition the structural shapes.

    // Left shoe (covers body left foot)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 38, height: 18)
        .offset(x: -23, y: 75)

    // Right shoe (covers body right foot)
    RoundedRectangle(cornerRadius: 8)
        .fill(palette.primary)
        .frame(width: 38, height: 18)
        .offset(x: 23, y: 75)
    """
}

// MARK: - Previews

struct ItemTemplates_Previews: PreviewProvider {
    static let palette = ColourPalette(
        primary: ColourPalette.from(hex: "#5B9BD5"),
        secondary: ColourPalette.from(hex: "#3A7BBF"),
        accent: ColourPalette.from(hex: "#FFD54F")
    )

    static var previews: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                // Top variants
                templateCard("Top\n(short sleeve)") {
                    TopItemTemplate(palette: palette, sleeveStyle: .short)
                    BodySkeletonView(category: "top")
                }
                templateCard("Top\n(long sleeve)") {
                    TopItemTemplate(palette: palette, sleeveStyle: .long)
                    BodySkeletonView(category: "top")
                }

                // Bottom variants
                templateCard("Bottom\n(short trousers)") {
                    BottomItemTemplate(palette: palette, style: .shortTrousers)
                    BodySkeletonView(category: "bottom")
                }
                templateCard("Bottom\n(long trousers)") {
                    BottomItemTemplate(palette: palette, style: .longTrousers)
                    BodySkeletonView(category: "bottom")
                }
                templateCard("Bottom\n(short skirt)") {
                    BottomItemTemplate(palette: palette, style: .shortSkirt)
                    BodySkeletonView(category: "bottom")
                }
                templateCard("Bottom\n(long skirt)") {
                    BottomItemTemplate(palette: palette, style: .longSkirt)
                    BodySkeletonView(category: "bottom")
                }

                // Shoes
                templateCard("Shoes") {
                    ShoesItemTemplate(palette: palette)
                    BodySkeletonView(category: "shoes")
                }
            }
            .padding()
        }
        .previewDisplayName("Item Templates — All Variants")
    }

    @ViewBuilder
    static func templateCard<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 150, height: 275)
                content()
            }
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

import SwiftUI

public struct ColourPalette: Sendable {
    public var primary: Color
    public var secondary: Color
    public var accent: Color
    public var background: Color

    public init(primary: Color, secondary: Color, accent: Color, background: Color = Color(white: 0.92)) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
    }

    public static func from(hex: String) -> Color {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}

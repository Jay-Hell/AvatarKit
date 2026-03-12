import SwiftUI

public enum SkinTone: String, CaseIterable, Sendable {
    case light
    case medium
    case dark

    public var color: Color {
        switch self {
        case .light:
            return ColourPalette.from(hex: "#FDDBB4")
        case .medium:
            return ColourPalette.from(hex: "#D4956A")
        case .dark:
            return ColourPalette.from(hex: "#8D5524")
        }
    }
}

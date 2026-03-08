import SwiftUI

public enum SkinTone: String, CaseIterable, Sendable {
    case light
    case medium
    case dark

    public var color: Color {
        switch self {
        case .light:
            return Color(red: 0.98, green: 0.87, blue: 0.75)
        case .medium:
            return Color(red: 0.82, green: 0.64, blue: 0.46)
        case .dark:
            return Color(red: 0.55, green: 0.36, blue: 0.24)
        }
    }
}

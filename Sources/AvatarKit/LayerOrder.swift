import Foundation

public enum LayerOrder: Int, CaseIterable, Comparable, Sendable {
    case background = 0
    case body = 10
    case shoes = 20
    case bottom = 30
    case top = 40
    case accessory = 50
    case hair = 60
    case pet = 70
    case expression = 80

    public static func < (lhs: LayerOrder, rhs: LayerOrder) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

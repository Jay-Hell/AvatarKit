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

    public init?(string: String) {
        switch string {
        case "background": self = .background
        case "body": self = .body
        case "shoes": self = .shoes
        case "bottom": self = .bottom
        case "top": self = .top
        case "accessory": self = .accessory
        case "hair": self = .hair
        case "pet": self = .pet
        case "expression": self = .expression
        default: return nil
        }
    }

    public var name: String {
        switch self {
        case .background: "background"
        case .body: "body"
        case .shoes: "shoes"
        case .bottom: "bottom"
        case .top: "top"
        case .accessory: "accessory"
        case .hair: "hair"
        case .pet: "pet"
        case .expression: "expression"
        }
    }
}

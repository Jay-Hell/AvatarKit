import SwiftUI

// MARK: - Top-Level Descriptor

public struct ItemDescriptor: Codable, Sendable {
    public let schemaVersion: Int
    public let itemId: String
    public let layerOrder: String
    public let shapes: [ShapeDescriptor]

    public init(schemaVersion: Int = 1, itemId: String, layerOrder: String, shapes: [ShapeDescriptor]) {
        self.schemaVersion = schemaVersion
        self.itemId = itemId
        self.layerOrder = layerOrder
        self.shapes = shapes
    }

    public static let currentSchemaVersion = 1
}

// MARK: - Fill Color

public enum FillColor: Codable, Sendable {
    case palette(String)
    case hex(String, opacity: Double)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let palette = try container.decodeIfPresent(String.self, forKey: .palette) {
            self = .palette(palette)
        } else if let hex = try container.decodeIfPresent(String.self, forKey: .hex) {
            let opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1.0
            self = .hex(hex, opacity: opacity)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "FillColor must have 'palette' or 'hex'")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .palette(let name):
            try container.encode(name, forKey: .palette)
        case .hex(let value, let opacity):
            try container.encode(value, forKey: .hex)
            if opacity != 1.0 {
                try container.encode(opacity, forKey: .opacity)
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case palette, hex, opacity
    }
}

// MARK: - Rotation Anchor

public enum RotationAnchor: String, Codable, Sendable {
    case center, top, bottom, leading, trailing
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    public var unitPoint: UnitPoint {
        switch self {
        case .center: .center
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

// MARK: - Common Fields

/// Positioning, rotation, and opacity shared by all shape types.
/// Decoded/encoded flat alongside shape-specific fields.
public struct CommonFields: Sendable {
    public var offsetX: CGFloat
    public var offsetY: CGFloat
    public var rotation: Double
    public var rotationAnchor: RotationAnchor
    public var opacity: Double
    public var overlays: [ShapeDescriptor]

    public init(
        offsetX: CGFloat = 0, offsetY: CGFloat = 0,
        rotation: Double = 0, rotationAnchor: RotationAnchor = .center,
        opacity: Double = 1.0, overlays: [ShapeDescriptor] = []
    ) {
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.rotation = rotation
        self.rotationAnchor = rotationAnchor
        self.opacity = opacity
        self.overlays = overlays
    }

    // Shared CodingKeys used by each shape data type
    enum CodingKeys: String, CodingKey {
        case offsetX, offsetY, rotation, rotationAnchor, opacity, overlays
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offsetX = try container.decodeIfPresent(CGFloat.self, forKey: .offsetX) ?? 0
        offsetY = try container.decodeIfPresent(CGFloat.self, forKey: .offsetY) ?? 0
        rotation = try container.decodeIfPresent(Double.self, forKey: .rotation) ?? 0
        rotationAnchor = try container.decodeIfPresent(RotationAnchor.self, forKey: .rotationAnchor) ?? .center
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1.0
        overlays = try container.decodeIfPresent([ShapeDescriptor].self, forKey: .overlays) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if offsetX != 0 { try container.encode(offsetX, forKey: .offsetX) }
        if offsetY != 0 { try container.encode(offsetY, forKey: .offsetY) }
        if rotation != 0 { try container.encode(rotation, forKey: .rotation) }
        if rotationAnchor != .center { try container.encode(rotationAnchor, forKey: .rotationAnchor) }
        if opacity != 1.0 { try container.encode(opacity, forKey: .opacity) }
        if !overlays.isEmpty { try container.encode(overlays, forKey: .overlays) }
    }
}

// MARK: - Shape Descriptor

public enum ShapeDescriptor: Codable, Sendable {
    case roundedRectangle(RoundedRectangleData)
    case circle(CircleData)
    case ellipse(EllipseData)
    case taperedRect(TaperedRectData)
    case quadCurve(QuadCurveData)

    /// Common positioning fields, regardless of shape type.
    public var common: CommonFields {
        switch self {
        case .roundedRectangle(let d): d.common
        case .circle(let d): d.common
        case .ellipse(let d): d.common
        case .taperedRect(let d): d.common
        case .quadCurve(let d): d.common
        }
    }

    // MARK: - Shape Data Types

    public struct RoundedRectangleData: Codable, Sendable {
        public let width: CGFloat
        public let height: CGFloat
        public let cornerRadius: CGFloat
        public let fill: FillColor
        public let common: CommonFields

        public init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat, fill: FillColor, common: CommonFields = .init()) {
            self.width = width
            self.height = height
            self.cornerRadius = cornerRadius
            self.fill = fill
            self.common = common
        }

        private enum CodingKeys: String, CodingKey {
            case width, height, cornerRadius, fill
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            width = try container.decode(CGFloat.self, forKey: .width)
            height = try container.decode(CGFloat.self, forKey: .height)
            cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
            fill = try container.decode(FillColor.self, forKey: .fill)
            common = try CommonFields(from: decoder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            try container.encode(cornerRadius, forKey: .cornerRadius)
            try container.encode(fill, forKey: .fill)
            try common.encode(to: encoder)
        }
    }

    public struct CircleData: Codable, Sendable {
        public let diameter: CGFloat
        public let fill: FillColor
        public let common: CommonFields

        public init(diameter: CGFloat, fill: FillColor, common: CommonFields = .init()) {
            self.diameter = diameter
            self.fill = fill
            self.common = common
        }

        private enum CodingKeys: String, CodingKey {
            case diameter, fill
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            diameter = try container.decode(CGFloat.self, forKey: .diameter)
            fill = try container.decode(FillColor.self, forKey: .fill)
            common = try CommonFields(from: decoder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(diameter, forKey: .diameter)
            try container.encode(fill, forKey: .fill)
            try common.encode(to: encoder)
        }
    }

    public struct EllipseData: Codable, Sendable {
        public let width: CGFloat
        public let height: CGFloat
        public let fill: FillColor
        public let common: CommonFields

        public init(width: CGFloat, height: CGFloat, fill: FillColor, common: CommonFields = .init()) {
            self.width = width
            self.height = height
            self.fill = fill
            self.common = common
        }

        private enum CodingKeys: String, CodingKey {
            case width, height, fill
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            width = try container.decode(CGFloat.self, forKey: .width)
            height = try container.decode(CGFloat.self, forKey: .height)
            fill = try container.decode(FillColor.self, forKey: .fill)
            common = try CommonFields(from: decoder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            try container.encode(fill, forKey: .fill)
            try common.encode(to: encoder)
        }
    }

    public struct TaperedRectData: Codable, Sendable {
        public let topWidth: CGFloat
        public let bottomWidth: CGFloat
        public let cornerRadius: CGFloat
        public let width: CGFloat
        public let height: CGFloat
        public let fill: FillColor
        public let common: CommonFields

        public init(topWidth: CGFloat, bottomWidth: CGFloat, cornerRadius: CGFloat, width: CGFloat, height: CGFloat, fill: FillColor, common: CommonFields = .init()) {
            self.topWidth = topWidth
            self.bottomWidth = bottomWidth
            self.cornerRadius = cornerRadius
            self.width = width
            self.height = height
            self.fill = fill
            self.common = common
        }

        private enum CodingKeys: String, CodingKey {
            case topWidth, bottomWidth, cornerRadius, width, height, fill
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            topWidth = try container.decode(CGFloat.self, forKey: .topWidth)
            bottomWidth = try container.decode(CGFloat.self, forKey: .bottomWidth)
            cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
            width = try container.decode(CGFloat.self, forKey: .width)
            height = try container.decode(CGFloat.self, forKey: .height)
            fill = try container.decode(FillColor.self, forKey: .fill)
            common = try CommonFields(from: decoder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(topWidth, forKey: .topWidth)
            try container.encode(bottomWidth, forKey: .bottomWidth)
            try container.encode(cornerRadius, forKey: .cornerRadius)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
            try container.encode(fill, forKey: .fill)
            try common.encode(to: encoder)
        }
    }

    public struct QuadCurveData: Codable, Sendable {
        public let startX: CGFloat
        public let startY: CGFloat
        public let endX: CGFloat
        public let endY: CGFloat
        public let controlX: CGFloat
        public let controlY: CGFloat
        public let lineWidth: CGFloat
        public let strokeColor: FillColor
        public let common: CommonFields

        public init(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat, controlX: CGFloat, controlY: CGFloat, lineWidth: CGFloat, strokeColor: FillColor, common: CommonFields = .init()) {
            self.startX = startX
            self.startY = startY
            self.endX = endX
            self.endY = endY
            self.controlX = controlX
            self.controlY = controlY
            self.lineWidth = lineWidth
            self.strokeColor = strokeColor
            self.common = common
        }

        private enum CodingKeys: String, CodingKey {
            case startX, startY, endX, endY, controlX, controlY, lineWidth, strokeColor
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            startX = try container.decode(CGFloat.self, forKey: .startX)
            startY = try container.decode(CGFloat.self, forKey: .startY)
            endX = try container.decode(CGFloat.self, forKey: .endX)
            endY = try container.decode(CGFloat.self, forKey: .endY)
            controlX = try container.decode(CGFloat.self, forKey: .controlX)
            controlY = try container.decode(CGFloat.self, forKey: .controlY)
            lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
            strokeColor = try container.decode(FillColor.self, forKey: .strokeColor)
            common = try CommonFields(from: decoder)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(startX, forKey: .startX)
            try container.encode(startY, forKey: .startY)
            try container.encode(endX, forKey: .endX)
            try container.encode(endY, forKey: .endY)
            try container.encode(controlX, forKey: .controlX)
            try container.encode(controlY, forKey: .controlY)
            try container.encode(lineWidth, forKey: .lineWidth)
            try container.encode(strokeColor, forKey: .strokeColor)
            try common.encode(to: encoder)
        }
    }

    // MARK: - Codable

    private enum TypeCodingKey: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeCodingKey.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "roundedRectangle":
            self = .roundedRectangle(try .init(from: decoder))
        case "circle":
            self = .circle(try .init(from: decoder))
        case "ellipse":
            self = .ellipse(try .init(from: decoder))
        case "taperedRect":
            self = .taperedRect(try .init(from: decoder))
        case "quadCurve":
            self = .quadCurve(try .init(from: decoder))
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unknown shape type: \(type)")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TypeCodingKey.self)
        switch self {
        case .roundedRectangle(let data):
            try container.encode("roundedRectangle", forKey: .type)
            try data.encode(to: encoder)
        case .circle(let data):
            try container.encode("circle", forKey: .type)
            try data.encode(to: encoder)
        case .ellipse(let data):
            try container.encode("ellipse", forKey: .type)
            try data.encode(to: encoder)
        case .taperedRect(let data):
            try container.encode("taperedRect", forKey: .type)
            try data.encode(to: encoder)
        case .quadCurve(let data):
            try container.encode("quadCurve", forKey: .type)
            try data.encode(to: encoder)
        }
    }
}

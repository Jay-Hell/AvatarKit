import Foundation

/// Validates an `ItemDescriptor` for structural correctness.
///
/// Use before saving or rendering to catch issues early:
/// ```swift
/// let errors = ShapeDescriptorValidator.validate(descriptor)
/// if errors.isEmpty { /* safe to render */ }
/// ```
public enum ShapeDescriptorValidator {

    public struct ValidationError: Sendable, CustomStringConvertible {
        public let path: String
        public let message: String

        public var description: String { "[\(path)] \(message)" }
    }

    public static func validate(_ descriptor: ItemDescriptor) -> [ValidationError] {
        var errors: [ValidationError] = []

        if descriptor.schemaVersion > ItemDescriptor.currentSchemaVersion {
            errors.append(.init(path: "schemaVersion", message: "Unsupported version \(descriptor.schemaVersion) (max \(ItemDescriptor.currentSchemaVersion))"))
        }

        if descriptor.itemId.isEmpty {
            errors.append(.init(path: "itemId", message: "Must not be empty"))
        }

        if LayerOrder(string: descriptor.layerOrder) == nil {
            errors.append(.init(path: "layerOrder", message: "Invalid layer order: '\(descriptor.layerOrder)'"))
        }

        if descriptor.shapes.isEmpty {
            errors.append(.init(path: "shapes", message: "Must contain at least one shape"))
        }

        for (index, shape) in descriptor.shapes.enumerated() {
            errors.append(contentsOf: validateShape(shape, path: "shapes[\(index)]"))
        }

        return errors
    }

    /// Validates JSON data directly, combining parse errors and structural validation.
    public static func validate(json: Data) -> [ValidationError] {
        let descriptor: ItemDescriptor
        do {
            descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: json)
        } catch {
            return [.init(path: "root", message: "Invalid JSON: \(error.localizedDescription)")]
        }
        return validate(descriptor)
    }

    // MARK: - Private

    private static func validateShape(_ shape: ShapeDescriptor, path: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        switch shape {
        case .roundedRectangle(let data):
            if data.width <= 0 { errors.append(.init(path: "\(path).width", message: "Must be positive")) }
            if data.height <= 0 { errors.append(.init(path: "\(path).height", message: "Must be positive")) }
            if data.cornerRadius < 0 { errors.append(.init(path: "\(path).cornerRadius", message: "Must not be negative")) }
            errors.append(contentsOf: validateFill(data.fill, path: "\(path).fill"))
            errors.append(contentsOf: validateOverlays(data.common.overlays, path: path))

        case .circle(let data):
            if data.diameter <= 0 { errors.append(.init(path: "\(path).diameter", message: "Must be positive")) }
            errors.append(contentsOf: validateFill(data.fill, path: "\(path).fill"))
            errors.append(contentsOf: validateOverlays(data.common.overlays, path: path))

        case .ellipse(let data):
            if data.width <= 0 { errors.append(.init(path: "\(path).width", message: "Must be positive")) }
            if data.height <= 0 { errors.append(.init(path: "\(path).height", message: "Must be positive")) }
            errors.append(contentsOf: validateFill(data.fill, path: "\(path).fill"))
            errors.append(contentsOf: validateOverlays(data.common.overlays, path: path))

        case .taperedRect(let data):
            if data.topWidth <= 0 { errors.append(.init(path: "\(path).topWidth", message: "Must be positive")) }
            if data.bottomWidth <= 0 { errors.append(.init(path: "\(path).bottomWidth", message: "Must be positive")) }
            if data.width <= 0 { errors.append(.init(path: "\(path).width", message: "Must be positive")) }
            if data.height <= 0 { errors.append(.init(path: "\(path).height", message: "Must be positive")) }
            if data.cornerRadius < 0 { errors.append(.init(path: "\(path).cornerRadius", message: "Must not be negative")) }
            errors.append(contentsOf: validateFill(data.fill, path: "\(path).fill"))
            errors.append(contentsOf: validateOverlays(data.common.overlays, path: path))

        case .quadCurve(let data):
            if data.lineWidth <= 0 { errors.append(.init(path: "\(path).lineWidth", message: "Must be positive")) }
            errors.append(contentsOf: validateFill(data.strokeColor, path: "\(path).strokeColor"))
            errors.append(contentsOf: validateOverlays(data.common.overlays, path: path))
        }

        return errors
    }

    private static let validPaletteNames: Set<String> = ["primary", "secondary", "accent", "skin"]

    private static func validateFill(_ fill: FillColor, path: String) -> [ValidationError] {
        switch fill {
        case .palette(let name):
            if !validPaletteNames.contains(name) {
                return [.init(path: path, message: "Invalid palette name: '\(name)'. Valid: \(validPaletteNames.sorted().joined(separator: ", "))")]
            }
        case .hex(let hex, let opacity):
            let stripped = hex.replacingOccurrences(of: "#", with: "")
            if stripped.count != 6 || UInt64(stripped, radix: 16) == nil {
                return [.init(path: path, message: "Invalid hex color: '\(hex)'")]
            }
            if opacity < 0 || opacity > 1 {
                return [.init(path: path, message: "Opacity must be 0-1, got \(opacity)")]
            }
        }
        return []
    }

    private static func validateOverlays(_ overlays: [ShapeDescriptor], path: String) -> [ValidationError] {
        var errors: [ValidationError] = []
        for (index, overlay) in overlays.enumerated() {
            errors.append(contentsOf: validateShape(overlay, path: "\(path).overlays[\(index)]"))
        }
        return errors
    }
}

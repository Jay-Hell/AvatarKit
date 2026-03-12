import SwiftUI

/// A concrete `AvatarLayer` created from a JSON shape descriptor.
///
/// Usage:
/// ```swift
/// let layer = try DynamicAvatarLayer.from(
///     json: jsonData,
///     palette: palette,
///     skinTone: .medium
/// )
/// var config = AvatarConfiguration(skinTone: .medium)
/// config.equippedItems[layer.layerOrder] = layer
/// ```
public struct DynamicAvatarLayer: AvatarLayer {
    public let itemID: String
    public let layerOrder: LayerOrder
    public let descriptor: ItemDescriptor
    public let palette: ColourPalette
    public let skinTone: SkinTone

    public init(descriptor: ItemDescriptor, palette: ColourPalette, skinTone: SkinTone) throws {
        guard descriptor.schemaVersion <= ItemDescriptor.currentSchemaVersion else {
            throw DynamicLayerError.unsupportedSchemaVersion(descriptor.schemaVersion)
        }
        guard let order = LayerOrder(string: descriptor.layerOrder) else {
            throw DynamicLayerError.invalidLayerOrder(descriptor.layerOrder)
        }
        self.itemID = descriptor.itemId
        self.layerOrder = order
        self.descriptor = descriptor
        self.palette = palette
        self.skinTone = skinTone
    }

    /// Creates a `DynamicAvatarLayer` from raw JSON data.
    public static func from(json: Data, palette: ColourPalette, skinTone: SkinTone) throws -> DynamicAvatarLayer {
        let descriptor = try JSONDecoder().decode(ItemDescriptor.self, from: json)
        return try DynamicAvatarLayer(descriptor: descriptor, palette: palette, skinTone: skinTone)
    }

    public func renderView() -> AnyView {
        AnyView(
            DynamicLayerView(descriptor: descriptor, palette: palette, skinTone: skinTone)
        )
    }
}

// MARK: - Errors

public enum DynamicLayerError: LocalizedError {
    case unsupportedSchemaVersion(Int)
    case invalidLayerOrder(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let version):
            "Unsupported schema version \(version). Please update the app."
        case .invalidLayerOrder(let order):
            "Invalid layer order: '\(order)'"
        }
    }
}

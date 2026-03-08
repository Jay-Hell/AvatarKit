import SwiftUI

public struct AvatarConfiguration {
    public var skinTone: SkinTone
    public var equippedItems: [LayerOrder: any AvatarLayer]

    public init(skinTone: SkinTone, equippedItems: [LayerOrder: any AvatarLayer] = [:]) {
        self.skinTone = skinTone
        self.equippedItems = equippedItems
    }

    public static var defaultConfiguration: AvatarConfiguration {
        AvatarConfiguration(skinTone: .medium, equippedItems: [:])
    }
}

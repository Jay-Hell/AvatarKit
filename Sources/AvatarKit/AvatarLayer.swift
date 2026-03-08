import SwiftUI

public protocol AvatarLayer {
    var itemID: String { get }
    var layerOrder: LayerOrder { get }
    func renderView() -> AnyView
}

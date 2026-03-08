import SwiftUI

public struct AvatarCompositorView: View {
    let configuration: AvatarConfiguration
    let palette: ColourPalette
    let showShadow: Bool

    public init(
        configuration: AvatarConfiguration,
        palette: ColourPalette = ColourPalette(
            primary: ColourPalette.from(hex: "#3B2F2F"),
            secondary: ColourPalette.from(hex: "#D6E4F0"),
            accent: ColourPalette.from(hex: "#5B9BD5")
        ),
        showShadow: Bool = false
    ) {
        self.configuration = configuration
        self.palette = palette
        self.showShadow = showShadow
    }

    public var body: some View {
        ZStack {
            ForEach(LayerOrder.allCases, id: \.self) { order in
                if let layer = configuration.equippedItems[order] {
                    layer.renderView()
                } else {
                    defaultLayer(for: order)
                }
            }
        }
        .frame(width: 200, height: 350)
        .clipped()
        .shadow(
            color: showShadow ? Color.black.opacity(0.25) : Color.clear,
            radius: showShadow ? 8 : 0,
            x: 0,
            y: showShadow ? 4 : 0
        )
    }

    @ViewBuilder
    private func defaultLayer(for order: LayerOrder) -> some View {
        switch order {
        case .background:
            BackgroundLayer(palette: palette)
        case .body:
            ZStack {
                BodyLayer(skinTone: configuration.skinTone)
                HeadLayer(skinTone: configuration.skinTone)
            }
        case .shoes:
            ShoesLayer()
        case .bottom:
            BottomLayer(palette: palette)
        case .top:
            TopLayer(palette: palette)
        case .accessory:
            AccessoryLayer(palette: palette)
        case .hair:
            HairLayer(palette: palette)
        case .pet:
            PetLayer()
        case .expression:
            FaceLayer()
        }
    }
}

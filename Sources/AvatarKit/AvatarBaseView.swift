import SwiftUI

// MARK: - Sub-views

public struct BackgroundLayer: View {
    let palette: ColourPalette

    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(palette.secondary)
            .frame(width: 200, height: 350)
    }
}

public struct BodyLayer: View {
    let skinTone: SkinTone

    public var body: some View {
        ZStack {
            Group {
                // Left arm (behind torso)
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 20, height: 55)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -52, y: -23)

                // Right arm (behind torso)
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 20, height: 55)
                    .rotationEffect(.degrees(8))
                    .offset(x: 52, y: -23)

                // Left leg
                RoundedRectangle(cornerRadius: 10)
                    .fill(skinTone.color)
                    .frame(width: 28, height: 65)
                    .offset(x: -16, y: 92)

                // Right leg
                RoundedRectangle(cornerRadius: 10)
                    .fill(skinTone.color)
                    .frame(width: 28, height: 65)
                    .offset(x: 16, y: 92)

                // Neck
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 12, height: 10)
                    .offset(y: -60)
            }

            Group {
                // Torso (on top of arm/leg connections)
                RoundedRectangle(cornerRadius: 14)
                    .fill(skinTone.color)
                    .frame(width: 80, height: 75)
                    .offset(y: -17)

                // Left hand
                Circle()
                    .fill(skinTone.color)
                    .frame(width: 18, height: 18)
                    .offset(x: -56, y: 7)

                // Right hand
                Circle()
                    .fill(skinTone.color)
                    .frame(width: 18, height: 18)
                    .offset(x: 56, y: 7)

                // Left foot
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 34, height: 18)
                    .offset(x: -20, y: 129)

                // Right foot
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 34, height: 18)
                    .offset(x: 20, y: 129)
            }
        }
    }
}

public struct HeadLayer: View {
    let skinTone: SkinTone

    public var body: some View {
        // Head
        Circle()
            .fill(skinTone.color)
            .frame(width: 75, height: 75)
            .offset(y: -100)
    }
}

public struct FaceLayer: View {
    public var body: some View {
        EmptyView()
    }
}

public struct HairLayer: View {
    let palette: ColourPalette

    public var body: some View {
        EmptyView()
    }
}

public struct TopLayer: View {
    let palette: ColourPalette

    public var body: some View {
        EmptyView()
    }
}

public struct BottomLayer: View {
    let palette: ColourPalette

    public var body: some View {
        EmptyView()
    }
}

public struct ShoesLayer: View {
    public var body: some View {
        EmptyView()
    }
}

public struct AccessoryLayer: View {
    let palette: ColourPalette

    public var body: some View {
        EmptyView()
    }
}

public struct PetLayer: View {
    public var body: some View {
        EmptyView()
    }
}

// MARK: - AvatarBaseView

public struct AvatarBaseView: View {
    let skinTone: SkinTone
    let palette: ColourPalette

    public init(skinTone: SkinTone, palette: ColourPalette) {
        self.skinTone = skinTone
        self.palette = palette
    }

    public var body: some View {
        ZStack {
            BackgroundLayer(palette: palette)
            BodyLayer(skinTone: skinTone)
            ShoesLayer()
            BottomLayer(palette: palette)
            TopLayer(palette: palette)
            HeadLayer(skinTone: skinTone)
            FaceLayer()
            HairLayer(palette: palette)
            AccessoryLayer(palette: palette)
            PetLayer()
        }
        .frame(width: 200, height: 350)
        .clipped()
    }
}

// MARK: - Preview

struct AvatarBaseView_Previews: PreviewProvider {
    static var previews: some View {
        let palette = ColourPalette(
            primary: ColourPalette.from(hex: "#3B2F2F"),
            secondary: ColourPalette.from(hex: "#D6E4F0"),
            accent: ColourPalette.from(hex: "#5B9BD5")
        )

        HStack(spacing: 20) {
            ForEach(SkinTone.allCases, id: \.self) { tone in
                VStack {
                    AvatarCompositorView(
                        configuration: AvatarConfiguration(skinTone: tone),
                        palette: palette
                    )
                    Text(tone.rawValue.capitalized)
                        .font(.caption)
                }
            }
        }
        .padding()
        .previewDisplayName("All Skin Tones")
    }
}

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
        // Torso
        RoundedRectangle(cornerRadius: 16)
            .fill(skinTone.color)
            .frame(width: 70, height: 90)
            .offset(y: 50)

        // Arms
        RoundedRectangle(cornerRadius: 8)
            .fill(skinTone.color)
            .frame(width: 20, height: 70)
            .offset(x: -50, y: 50)

        RoundedRectangle(cornerRadius: 8)
            .fill(skinTone.color)
            .frame(width: 20, height: 70)
            .offset(x: 50, y: 50)
    }
}

public struct HeadLayer: View {
    let skinTone: SkinTone

    public var body: some View {
        // Neck
        RoundedRectangle(cornerRadius: 4)
            .fill(skinTone.color)
            .frame(width: 20, height: 16)
            .offset(y: -2)

        // Head
        Ellipse()
            .fill(skinTone.color)
            .frame(width: 72, height: 80)
            .offset(y: -50)

        // Ears
        Circle()
            .fill(skinTone.color)
            .frame(width: 16, height: 16)
            .offset(x: -38, y: -48)

        Circle()
            .fill(skinTone.color)
            .frame(width: 16, height: 16)
            .offset(x: 38, y: -48)
    }
}

public struct FaceLayer: View {
    public var body: some View {
        // Eyes
        Circle()
            .fill(Color.white)
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .fill(Color(red: 0.25, green: 0.2, blue: 0.15))
                    .frame(width: 10, height: 10)
            )
            .offset(x: -14, y: -54)

        Circle()
            .fill(Color.white)
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .fill(Color(red: 0.25, green: 0.2, blue: 0.15))
                    .frame(width: 10, height: 10)
            )
            .offset(x: 14, y: -54)

        // Nose
        Ellipse()
            .fill(Color(red: 0.7, green: 0.5, blue: 0.4).opacity(0.4))
            .frame(width: 8, height: 6)
            .offset(y: -42)

        // Mouth
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 0.85, green: 0.45, blue: 0.45))
            .frame(width: 20, height: 6)
            .offset(y: -32)
    }
}

public struct HairLayer: View {
    let palette: ColourPalette

    public var body: some View {
        // Short, gender-neutral hair
        Ellipse()
            .fill(palette.primary)
            .frame(width: 78, height: 44)
            .offset(y: -82)

        RoundedRectangle(cornerRadius: 6)
            .fill(palette.primary)
            .frame(width: 74, height: 20)
            .offset(y: -68)
    }
}

public struct TopLayer: View {
    let palette: ColourPalette

    public var body: some View {
        // T-shirt
        RoundedRectangle(cornerRadius: 14)
            .fill(palette.accent)
            .frame(width: 76, height: 70)
            .offset(y: 42)

        // Sleeves
        RoundedRectangle(cornerRadius: 8)
            .fill(palette.accent)
            .frame(width: 24, height: 30)
            .offset(x: -48, y: 32)

        RoundedRectangle(cornerRadius: 8)
            .fill(palette.accent)
            .frame(width: 24, height: 30)
            .offset(x: 48, y: 32)
    }
}

public struct BottomLayer: View {
    let palette: ColourPalette

    public var body: some View {
        // Trousers
        RoundedRectangle(cornerRadius: 4)
            .fill(palette.primary.opacity(0.7))
            .frame(width: 34, height: 60)
            .offset(x: -18, y: 110)

        RoundedRectangle(cornerRadius: 4)
            .fill(palette.primary.opacity(0.7))
            .frame(width: 34, height: 60)
            .offset(x: 18, y: 110)

        // Waistband
        RoundedRectangle(cornerRadius: 4)
            .fill(palette.primary.opacity(0.8))
            .frame(width: 72, height: 12)
            .offset(y: 82)
    }
}

public struct ShoesLayer: View {
    public var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
            .frame(width: 32, height: 14)
            .offset(x: -18, y: 144)

        RoundedRectangle(cornerRadius: 6)
            .fill(Color(red: 0.3, green: 0.3, blue: 0.3))
            .frame(width: 32, height: 14)
            .offset(x: 18, y: 144)
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

#Preview("All Skin Tones") {
    let palette = ColourPalette(
        primary: ColourPalette.from(hex: "#3B2F2F"),
        secondary: ColourPalette.from(hex: "#D6E4F0"),
        accent: ColourPalette.from(hex: "#5B9BD5")
    )

    HStack(spacing: 20) {
        ForEach(SkinTone.allCases, id: \.self) { tone in
            VStack {
                AvatarBaseView(skinTone: tone, palette: palette)
                Text(tone.rawValue.capitalized)
                    .font(.caption)
            }
        }
    }
    .padding()
}

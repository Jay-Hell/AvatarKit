import SwiftUI

// MARK: - Shapes

public struct TaperedRect: Shape {
    public var topWidth: CGFloat
    public var bottomWidth: CGFloat
    public var cornerRadius: CGFloat

    public func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let tl = CGPoint(x: midX - topWidth / 2, y: rect.minY)
        let tr = CGPoint(x: midX + topWidth / 2, y: rect.minY)
        let br = CGPoint(x: midX + bottomWidth / 2, y: rect.maxY)
        let bl = CGPoint(x: midX - bottomWidth / 2, y: rect.maxY)

        var path = Path()
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addArc(tangent1End: tr, tangent2End: br, radius: cornerRadius)
        path.addArc(tangent1End: br, tangent2End: bl, radius: cornerRadius)
        path.addArc(tangent1End: bl, tangent2End: tl, radius: cornerRadius)
        path.addArc(tangent1End: tl, tangent2End: tr, radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

// MARK: - Sub-views

public struct BackgroundLayer: View {
    let palette: ColourPalette

    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(palette.secondary)
            .frame(width: 150, height: 275)
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
                    .rotationEffect(.degrees(30), anchor: .top)
                    .offset(x: -22, y: -6.5)

                // Right arm (behind torso)
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 20, height: 55)
                    .rotationEffect(.degrees(-30), anchor: .top)
                    .offset(x: 22, y: -6.5)

                // Left leg
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 28, height: 37)
                    .rotationEffect(.degrees(8.5))
                    .offset(x: -17, y: 52.5)

                // Right leg
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 28, height: 37)
                    .rotationEffect(.degrees(-8.5))
                    .offset(x: 17, y: 52.5)

                // Neck
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 14, height: 8)
                    .offset(y: -40)
            }

            Group {
                // Torso (on top of arm/leg connections)
                TaperedRect(topWidth: 54, bottomWidth: 65, cornerRadius: 9)
                    .fill(skinTone.color)
                    .frame(width: 65, height: 57)
                    .offset(y: -8)

                // Left hand
                Circle()
                    .fill(skinTone.color)
                    .frame(width: 22, height: 22)
                    .offset(x: -49.5, y: 15)

                // Right hand
                Circle()
                    .fill(skinTone.color)
                    .frame(width: 22, height: 22)
                    .offset(x: 49.5, y: 15)

                // Left foot
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 34, height: 14)
                    .offset(x: -23, y: 75)

                // Right foot
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinTone.color)
                    .frame(width: 34, height: 14)
                    .offset(x: 23, y: 75)
            }
        }
    }
}

public struct HeadLayer: View {
    let skinTone: SkinTone

    public var body: some View {
        ZStack {
            // Left ear
            Circle()
                .fill(skinTone.color)
                .frame(width: 22, height: 22)
                .offset(x: -34.5, y: -75)

            // Right ear
            Circle()
                .fill(skinTone.color)
                .frame(width: 22, height: 22)
                .offset(x: 34.5, y: -75)

            // Head
            Circle()
                .fill(skinTone.color)
                .frame(width: 75, height: 75)
                .offset(y: -78)
        }
    }
}

public struct FaceLayer: View {
    public var body: some View {
        // Left eye
        Circle()
            .fill(ColourPalette.from(hex: "#3D2B1F"))
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 3, height: 3)
                    .offset(x: 2, y: -2)
            )
            .offset(x: -15, y: -81)

        // Right eye
        Circle()
            .fill(ColourPalette.from(hex: "#3D2B1F"))
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 3, height: 3)
                    .offset(x: 2, y: -2)
            )
            .offset(x: 15, y: -81)

        // Left cheek
        Ellipse()
            .fill(ColourPalette.from(hex: "#FF9999").opacity(0.4))
            .frame(width: 14, height: 8)
            .offset(x: -22, y: -69)

        // Right cheek
        Ellipse()
            .fill(ColourPalette.from(hex: "#FF9999").opacity(0.4))
            .frame(width: 14, height: 8)
            .offset(x: 22, y: -69)

        // Mouth
        Path { path in
            path.move(to: CGPoint(x: 66, y: 74.5))
            path.addQuadCurve(to: CGPoint(x: 84, y: 74.5),
                              control: CGPoint(x: 75, y: 80.5))
        }
        .stroke(ColourPalette.from(hex: "#3D2B1F"), lineWidth: 1.5)
        .frame(width: 150, height: 275)
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
        // Left strap
        RoundedRectangle(cornerRadius: 4)
            .fill(ColourPalette.from(hex: "#DDDDDD"))
            .frame(width: 12, height: 10)
            .offset(x: -18, y: -36)

        // Right strap
        RoundedRectangle(cornerRadius: 4)
            .fill(ColourPalette.from(hex: "#DDDDDD"))
            .frame(width: 12, height: 10)
            .offset(x: 18, y: -36)

        // Main body
        TaperedRect(topWidth: 54, bottomWidth: 65, cornerRadius: 9)
            .fill(ColourPalette.from(hex: "#DDDDDD"))
            .frame(width: 65, height: 57)
            .offset(y: -8)
    }
}

public struct BottomLayer: View {
    let palette: ColourPalette

    public var body: some View {
        // Left leg
        RoundedRectangle(cornerRadius: 4)
            .fill(ColourPalette.from(hex: "#8A8A8A"))
            .frame(width: 30, height: 28)
            .rotationEffect(.degrees(8.5))
            .offset(x: -16, y: 42)

        // Right leg
        RoundedRectangle(cornerRadius: 4)
            .fill(ColourPalette.from(hex: "#8A8A8A"))
            .frame(width: 30, height: 28)
            .rotationEffect(.degrees(-8.5))
            .offset(x: 16, y: 42)

        // Waistband
        RoundedRectangle(cornerRadius: 4)
            .fill(ColourPalette.from(hex: "#8A8A8A"))
            .frame(width: 62, height: 12)
            .offset(y: 28)
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
            Group {
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
            .offset(y: 17)
        }
        .frame(width: 150, height: 275)
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

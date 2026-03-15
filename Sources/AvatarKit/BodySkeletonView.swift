import SwiftUI

/// Renders semi-transparent red silhouettes of body parts relevant to a given
/// clothing category. Intended for use in the admin app to visually verify that
/// generated items correctly cover the underlying body.
///
/// All positions, sizes, rotations, and offsets are taken verbatim from
/// ``BodyLayer`` and ``HeadLayer`` in `AvatarBaseView.swift`.
public struct BodySkeletonView: View {
    let category: String

    private let fill = Color.red.opacity(0.25)

    public init(category: String) {
        self.category = category
    }

    public var body: some View {
        ZStack {
            Group {
                switch category {
                case "top":
                    topSkeleton
                case "bottom":
                    bottomSkeleton
                case "shoes":
                    shoesSkeleton
                case "accessory":
                    accessorySkeleton
                case "expression":
                    expressionSkeleton
                default:
                    EmptyView()
                }
            }
            .offset(y: 17)
        }
        .frame(width: 150, height: 275)
    }

    // MARK: - Top: torso, left arm, right arm

    private var topSkeleton: some View {
        ZStack {
            // Torso — TaperedRect topWidth:54 bottomWidth:65 cornerRadius:9, frame 65×57, offset y:-8
            TaperedRect(topWidth: 54, bottomWidth: 65, cornerRadius: 9)
                .fill(fill)
                .frame(width: 65, height: 57)
                .offset(y: -8)

            // Left arm — RoundedRectangle cornerRadius:8, frame 20×55, rotation 30° anchor .top, offset x:-22 y:-6.5
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 20, height: 55)
                .rotationEffect(.degrees(30), anchor: .top)
                .offset(x: -22, y: -6.5)

            // Right arm — RoundedRectangle cornerRadius:8, frame 20×55, rotation -30° anchor .top, offset x:22 y:-6.5
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 20, height: 55)
                .rotationEffect(.degrees(-30), anchor: .top)
                .offset(x: 22, y: -6.5)
        }
    }

    // MARK: - Bottom: left leg, right leg, left foot, right foot

    private var bottomSkeleton: some View {
        ZStack {
            // Left leg — RoundedRectangle cornerRadius:8, frame 28×37, rotation 8.5°, offset x:-17 y:52.5
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 28, height: 37)
                .rotationEffect(.degrees(8.5))
                .offset(x: -17, y: 52.5)

            // Right leg — RoundedRectangle cornerRadius:8, frame 28×37, rotation -8.5°, offset x:17 y:52.5
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 28, height: 37)
                .rotationEffect(.degrees(-8.5))
                .offset(x: 17, y: 52.5)

            // Left foot — RoundedRectangle cornerRadius:8, frame 34×14, offset x:-23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 34, height: 14)
                .offset(x: -23, y: 75)

            // Right foot — RoundedRectangle cornerRadius:8, frame 34×14, offset x:23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 34, height: 14)
                .offset(x: 23, y: 75)
        }
    }

    // MARK: - Shoes: left foot, right foot

    private var shoesSkeleton: some View {
        ZStack {
            // Left foot — RoundedRectangle cornerRadius:8, frame 34×14, offset x:-23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 34, height: 14)
                .offset(x: -23, y: 75)

            // Right foot — RoundedRectangle cornerRadius:8, frame 34×14, offset x:23 y:75
            RoundedRectangle(cornerRadius: 8)
                .fill(fill)
                .frame(width: 34, height: 14)
                .offset(x: 23, y: 75)
        }
    }

    // MARK: - Accessory: head, left ear, right ear

    private var accessorySkeleton: some View {
        ZStack {
            // Left ear — Circle frame 22×22, offset x:-34.5 y:-75
            Circle()
                .fill(fill)
                .frame(width: 22, height: 22)
                .offset(x: -34.5, y: -75)

            // Right ear — Circle frame 22×22, offset x:34.5 y:-75
            Circle()
                .fill(fill)
                .frame(width: 22, height: 22)
                .offset(x: 34.5, y: -75)

            // Head — Circle frame 75×75, offset y:-78
            Circle()
                .fill(fill)
                .frame(width: 75, height: 75)
                .offset(y: -78)
        }
    }

    // MARK: - Expression: head circle only

    private var expressionSkeleton: some View {
        // Head — Circle frame 75×75, offset y:-78
        Circle()
            .fill(fill)
            .frame(width: 75, height: 75)
            .offset(y: -78)
    }
}

// MARK: - Preview

struct BodySkeletonView_Previews: PreviewProvider {
    static let categories = ["top", "bottom", "shoes", "accessory", "expression", "background", "pet"]

    static var previews: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 150, height: 275)
                            BodySkeletonView(category: category)
                        }
                        Text(category)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .previewDisplayName("BodySkeletonView — All Categories")
    }
}

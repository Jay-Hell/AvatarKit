// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AvatarKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AvatarKit",
            targets: ["AvatarKit"]
        ),
    ],
    targets: [
        .target(
            name: "AvatarKit"
        ),
        .testTarget(
            name: "AvatarKitTests",
            dependencies: ["AvatarKit"]
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureFavorites",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureFavorites", targets: ["FeatureFavorites"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureFavorites",
            dependencies: ["Core", "Domain", "DesignSystem"]
        ),
        .testTarget(
            name: "FeatureFavoritesTests",
            dependencies: ["FeatureFavorites", "SharedTesting"]
        )
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureFavorites",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureFavoritesCore", targets: ["FeatureFavoritesCore"]),
        .library(name: "FeatureFavoritesUI", targets: ["FeatureFavoritesUI"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureFavoritesCore",
            dependencies: ["Core", "Domain"]
        ),
        .target(
            name: "FeatureFavoritesUI",
            dependencies: [
                "FeatureFavoritesCore",
                .product(name: "DesignSystem", package: "DesignSystem", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "FeatureFavoritesTests",
            dependencies: ["FeatureFavoritesCore", "SharedTesting"]
        )
    ]
)

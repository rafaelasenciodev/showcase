// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureSettings",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureSettingsCore", targets: ["FeatureSettingsCore"]),
        .library(name: "FeatureSettingsUI", targets: ["FeatureSettingsUI"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureSettingsCore",
            dependencies: ["Core", "Domain"]
        ),
        .target(
            name: "FeatureSettingsUI",
            dependencies: [
                "FeatureSettingsCore",
                .product(name: "DesignSystem", package: "DesignSystem", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "FeatureSettingsTests",
            dependencies: ["FeatureSettingsCore", "SharedTesting"]
        )
    ]
)

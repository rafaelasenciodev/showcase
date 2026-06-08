// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureSettings",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureSettings", targets: ["FeatureSettings"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureSettings",
            dependencies: ["Core", "Domain", "DesignSystem"]
        ),
        .testTarget(
            name: "FeatureSettingsTests",
            dependencies: ["FeatureSettings", "SharedTesting"]
        )
    ]
)

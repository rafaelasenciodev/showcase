// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureArticles",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureArticles", targets: ["FeatureArticles"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureArticles",
            dependencies: ["Core", "Domain", "DesignSystem"]
        ),
        .testTarget(
            name: "FeatureArticlesTests",
            dependencies: ["FeatureArticles", "SharedTesting"]
        )
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureArticles",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "FeatureArticlesCore", targets: ["FeatureArticlesCore"]),
        .library(name: "FeatureArticlesUI", targets: ["FeatureArticlesUI"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain"),
        .package(path: "../DesignSystem"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "FeatureArticlesCore",
            dependencies: ["Core", "Domain"]
        ),
        .target(
            name: "FeatureArticlesUI",
            dependencies: [
                "FeatureArticlesCore",
                .product(name: "DesignSystem", package: "DesignSystem", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "FeatureArticlesTests",
            dependencies: ["FeatureArticlesCore", "SharedTesting"]
        )
    ]
)

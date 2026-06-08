// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedTesting",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SharedTesting", targets: ["SharedTesting"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "SharedTesting",
            dependencies: ["Core", "Domain"]
        )
    ]
)

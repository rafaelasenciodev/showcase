// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Domain", targets: ["Domain"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../SharedTesting")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                .product(name: "SharedTesting", package: "SharedTesting")
            ]
        )
    ]
)

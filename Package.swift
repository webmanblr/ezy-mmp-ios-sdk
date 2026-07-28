// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "EzyMMP",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "EzyMMP",
            targets: ["EzyMMP"]
        ),
    ],
    targets: [
        .target(
            name: "EzyMMP",
            dependencies: [],
            path: "Sources/EzyMMP"
        ),
        .testTarget(
            name: "EzyMMPTests",
            dependencies: ["EzyMMP"],
            path: "Tests/EzyMMPTests"
        ),
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VisionSnipCore",
    platforms: [.macOS(.v14), .visionOS(.v2)],
    products: [.library(name: "VisionSnipCore", targets: ["VisionSnipCore"])],
    targets: [
        .target(name: "VisionSnipCore"),
        .testTarget(name: "VisionSnipCoreTests", dependencies: ["VisionSnipCore"])
    ]
)

// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "xcproj",
    products: [
        .library(name: "xcproj", targets: ["xcproj"]),
        ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMajor(from: "0.8.0")),
        .package(url: "https://github.com/tadija/AEXML.git", .upToNextMajor(from: "4.1.0")),
        ],
    targets: [
        .target(name: "xcproj", dependencies: ["PathKit", "AEXML"]),
        .testTarget(name: "xcprojTests", dependencies: ["xcproj"]),
        ]
)

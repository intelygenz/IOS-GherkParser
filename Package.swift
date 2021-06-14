// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GherkParser",
    products: [
        .library(
            name: "GherkParser",
            targets: ["GherkParser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GherkParser",
            dependencies: []),
        .testTarget(
            name: "GherkParserTests",
            dependencies: ["GherkParser"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeDebug",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "XcodeDebug",
            targets: ["XcodeDebug"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/anconaesselmann/FileUrlExtensions", from: "0.0.2"),
        .package(url: "https://github.com/anconaesselmann/YetAnotherLogger", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "XcodeDebug",
            dependencies: ["FileUrlExtensions", "YetAnotherLogger"]
        ),
    ]
)

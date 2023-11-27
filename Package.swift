// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeDebug",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "XcodeDebug",
            targets: ["XcodeDebug"]),
    ],
    targets: [
        .target(
            name: "XcodeDebug"
        ),
    ]
)

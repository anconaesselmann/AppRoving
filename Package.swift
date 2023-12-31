// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppRoving",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "AppRoving",
            targets: ["AppRoving"]),
    ],
    targets: [
        .target(
            name: "AppRoving"
        ),
    ]
)

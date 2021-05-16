// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeoHex3.swift",
    products: [
        .library(
            name: "GeoHex3Swift",
            targets: ["GeoHex3Swift"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GeoHex3Swift",
            dependencies: []
        ),
        .testTarget(
            name: "GeoHex3SwiftTests",
            dependencies: ["GeoHex3Swift"]
        ),
    ]
)

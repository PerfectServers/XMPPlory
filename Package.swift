// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMPPlory",
    products: [
        .library(
            name: "XMPPlory",
            targets: ["XMPPlory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-XML.git", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "XMPPlory",
            dependencies: ["PerfectXML"]),
        .testTarget(
            name: "XMPPloryTests",
            dependencies: ["XMPPlory"]),
    ]
)

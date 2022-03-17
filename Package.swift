// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QrPayFramework",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "QrPayFramework",
            targets: ["QrPayFramework"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "QrPayFramework",
            dependencies: [],
            path: "Sources/",
            resources: [
                .process("QrPayFramework/Resources")
            ]),
        .testTarget(
            name: "QrPayFrameworkTests",
            dependencies: ["QrPayFramework"]),
    ]
)

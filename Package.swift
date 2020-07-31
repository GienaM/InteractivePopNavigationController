// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InteractivePopNavigationController",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "InteractivePopNavigationController",
            targets: ["InteractivePopNavigationController"]),
    ],
    targets: [
        .target(
            name: "InteractivePopNavigationController",
            dependencies: []),
        .testTarget(
            name: "InteractivePopNavigationControllerTests",
            dependencies: ["InteractivePopNavigationController"]),
    ]
)

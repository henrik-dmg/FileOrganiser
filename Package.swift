// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileOrganiser",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "file-organiser",
            targets: ["FileOrganiser"]
        ),
        .library(
            name: "FileOrganiserKit",
            targets: ["FileOrganiserKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/henrik-dmg/CLIFoundation", branch: "main"),
        .package(url: "https://github.com/ChimeHQ/GlobPattern", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FileOrganiserKit",
            dependencies: [
                "CLIFoundation",
                "GlobPattern",
            ]
        ),
        .testTarget(
            name: "FileOrganiserKitTests",
            dependencies: [
                "FileOrganiserKit"
            ]
        ),
        .executableTarget(
            name: "FileOrganiser",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "FileOrganiserKit",
            ]
        ),
    ]
)

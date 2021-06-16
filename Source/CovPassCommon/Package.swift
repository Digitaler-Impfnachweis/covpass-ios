// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CovPassCommon",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CovPassCommon",
            targets: ["CovPassCommon"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Keychain", path: "../ios-keychain"),
        .package(name: "Scanner", path: "../ios-scanner"),
        .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit", from: "6.13.2"),
        .package(name: "SwiftCBOR", url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CovPassCommon",
            dependencies: ["Keychain", "SwiftCBOR", "Scanner", "PromiseKit"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CovPassCommonTests",
            dependencies: ["CovPassCommon"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CovPassCommonIntegrationTests",
            dependencies: ["CovPassCommon"],
            resources: [.process("Resources")]
        )
    ]
)

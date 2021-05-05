// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaccinationCommon",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VaccinationCommon",
            targets: ["VaccinationCommon"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Keychain", url: "https://github.com/IBM/ios-keychain", from: "0.0.4"),
        .package(name: "Scanner", url: "https://github.com/DanielMandea/ios-scanner.git", from: "0.0.1"),
        .package(name: "SwiftCBOR", url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.1.0"),
        .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit", from: "6.13.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "VaccinationCommon",
            dependencies: ["Keychain", "SwiftCBOR", "Scanner", "PromiseKit"]),
        .testTarget(
            name: "VaccinationCommonTests",
            dependencies: ["VaccinationCommon"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "VaccinationCommonIntegrationTests",
            dependencies: ["VaccinationCommon"],
            resources: [.process("Resources")]),
    ]
)

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
        .package(name: "Scanner", path: "../ios-scanner"),
        .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit", from: "6.13.2"),
        .package(name: "SwiftCBOR", url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.1.0"),
        .package(name: "ASN1Decoder", url: "https://github.com/filom/ASN1Decoder", from: "1.7.1"),
        .package(name: "CertLogic", url: "https://github.com/eu-digital-green-certificates/dgc-certlogic-ios", .revision("95e85e43a3cc028d9d6a245104754ea1c5e76cdd")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CovPassCommon",
            dependencies: ["SwiftCBOR", "Scanner", "PromiseKit", "ASN1Decoder", "CertLogic"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CovPassCommonTests",
            dependencies: ["CovPassCommon"],
            resources: [.process("Resources")]
        )
    ]
)

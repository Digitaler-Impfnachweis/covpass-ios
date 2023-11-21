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
        .package(name: "Scanner", url: "https://github.com/IBM/ios-scanner", from: "1.0.5"),
        .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit", from: "8.1.1"),
        .package(name: "SwiftCBOR", url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.4.6"),
        .package(name: "ASN1Decoder", url: "https://github.com/filom/ASN1Decoder", from: "1.9.0"),
        .package(name: "CertLogic", url: "https://github.com/Digitaler-Impfnachweis/dgc-certlogic-ios-covpass.git", .branch("main")),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", from: "2.6.3"),
        .package(name: "CryptoSwift", url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CovPassCommon",
            dependencies: ["SwiftCBOR", "Scanner", "PromiseKit", "ASN1Decoder", "CertLogic", "JWTDecode", "CryptoSwift"],
            resources: [.process("Resources")],
            swiftSettings: [.define("SPM")]
        ),
        .testTarget(
            name: "CovPassCommonTests",
            dependencies: ["CovPassCommon"],
            resources: [.process("Resources")]
        )
    ]
)

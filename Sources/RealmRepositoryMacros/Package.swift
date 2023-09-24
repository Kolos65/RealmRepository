// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RealmRepositoryMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "RealmRepositoryMacros",
            targets: ["RealmRepositoryMacros"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", exact: "509.0.0")
    ],
    targets: [
        .macro(
            name: "RealmRepositoryMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "RealmRepositoryMacros", dependencies: ["RealmRepositoryMacrosPlugin"])
    ]
)

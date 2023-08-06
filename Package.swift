// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RealmRepository",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "RealmRepository",
            targets: [
                "RealmRepository"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/realm-swift.git",
            from: "10.42.0"
        )
    ],
    targets: [
        .target(
            name: "RealmRepository",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources/RealmRepository/"
        ),
        .testTarget(
            name: "RealmRepositoryTests",
            dependencies: [
                "RealmRepository"
            ],
            path: "Tests/RealmRepository/"
        )
    ]
)

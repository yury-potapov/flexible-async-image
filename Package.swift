// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "flexible-async-image",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FlexibleAsyncImage",
            targets: ["FlexibleAsyncImage"]
        ),
        .library(
            name: "FlexibleAsyncImageKingfisherAdapter",
            targets: ["FlexibleAsyncImageKingfisherAdapter"]
        )
    ],
    targets: [
        .target(name: "FlexibleAsyncImage"),
        .target(name: "FlexibleAsyncImageKingfisherAdapter"),
        .target(name: "FlexibleAsyncImageFileManagerAdapter"),
        .target(name: "FlexibleAsyncImageAVFoundationAdapter")
    ]
)

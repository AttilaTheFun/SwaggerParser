// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwaggerParser",
    products: [
        .library(
            name: "SwaggerParser",
            type: .static,
            targets: ["SwaggerParser"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwaggerParser",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwaggerParserTests",
            dependencies: [],
            path: "Tests"
        ),
    ]
)

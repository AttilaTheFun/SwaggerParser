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
            dependencies: ["OpenAPI", "OpenAPI2", "OpenAPI3"],
            path: "Sources",
            sources: ["Swagger.swift"]
        ),
        .target(
            name: "OpenAPI",
            dependencies: [],
            path: "Sources",
            sources: ["OpenAPI"]
        ),
        .target(
            name: "OpenAPI3",
            dependencies: ["OpenAPI"],
            path: "Sources",
            sources: ["OpenAPI3"]
        ),
        .target(
            name: "OpenAPI2",
            dependencies: ["OpenAPI"],
            path: "Sources",
            sources: ["OpenAPI2"]
        ),
        .testTarget(
            name: "SwaggerParserTests",
            dependencies: ["OpenAPI", "OpenAPI2", "OpenAPI3"],
            path: "Tests"
        ),
    ]
)

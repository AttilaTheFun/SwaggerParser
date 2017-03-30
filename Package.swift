// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwaggerParser",
    dependencies: [
        .Package(url: "https://github.com/Hearst-DD/ObjectMapper.git", majorVersion: 2)
    ]
)

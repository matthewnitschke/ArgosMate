// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ArgosMate",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ArgosMate",
            targets: ["ArgosMate"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ArgosMate",
            dependencies: [],
            path: "Sources/ArgosMate",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
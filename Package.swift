// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TowersSolver",
    products: [
        .executable(name: "App", targets: ["App"]),
        .library(name: "LoopySolver", targets: ["LoopySolver"]),
        .library(name: "NetSolver", targets: ["NetSolver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/MiniLexer.git", from: "0.11.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("1.1.3")),
    ],
    targets: [
        .target(name: "Console"),
        .target(name: "Interval"),
        .target(name: "Commons", dependencies: ["MiniLexer"]),
        .target(name: "Geometry", dependencies: ["Commons"]),
        .target(name: "TowersSolver", dependencies: ["Console", "Geometry"]),
        .target(name: "LoopySolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "NetSolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "SignpostSolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "App", dependencies: [
            "TowersSolver",
            "LoopySolver",
            "NetSolver",
            "SignpostSolver",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        // Tests
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Geometry"],
            path: "Tests/GeometryTests"
        ),
        .testTarget(
            name: "IntervalTests",
            dependencies: ["Interval"],
            path: "Tests/IntervalTests"
        ),
        .testTarget(
            name: "CommonsTests",
            dependencies: ["Commons"],
            path: "Tests/CommonsTests"
        ),
        .testTarget(
            name: "TowersSolverTests",
            dependencies: ["TowersSolver"],
            path: "Tests/TowersSolverTests"
        ),
        .testTarget(
            name: "LoopySolverTests",
            dependencies: ["LoopySolver"],
            path: "Tests/LoopySolverTests"
        ),
        .testTarget(
            name: "NetSolverTests",
            dependencies: ["NetSolver"],
            path: "Tests/NetSolverTests"
        ),
        .testTarget(
            name: "SignpostSolverTests",
            dependencies: ["SignpostSolver"],
            path: "Tests/SignpostSolverTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "MiniLexer"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

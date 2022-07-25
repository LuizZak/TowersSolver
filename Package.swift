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
    dependencies: [],
    targets: [
        .target(name: "Console"),
        .target(name: "Interval"),
        .target(name: "Commons"),
        .target(name: "Geometry", dependencies: ["Commons"]),
        .target(name: "TowersSolver", dependencies: ["Console", "Geometry"]),
        .target(name: "LoopySolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "NetSolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "SignpostSolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
        .target(name: "App", dependencies: ["TowersSolver"]),
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
    ],
    swiftLanguageVersions: [.v5]
)

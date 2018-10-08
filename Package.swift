// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TowersSolver",
    products: [
        .executable(name: "App", targets: ["App"]),
        .library(name: "LoopySolver", targets: ["LoopySolver"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Console"),
        .target(name: "Interval"),
        .target(name: "Commons"),
        .target(name: "Geometry", dependencies: ["Commons"]),
        .target(name: "TowersSolver", dependencies: ["Console", "Geometry"]),
        .target(name: "LoopySolver", dependencies: ["Console", "Geometry", "Interval", "Commons"]),
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
        )
    ]
)

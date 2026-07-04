// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mercator",
    platforms: [.macOS(.v15),
                .iOS(.v17)],
    products: [
        .library(name: "Mercator",
                 targets: ["Mercator"])
    ],
    dependencies: [
        .package(path: "../Alluvium"),
        .package(path: "../Bivouac"),
        .package(path: "../Deltille"),
        .package(path: "../Harvest"),
        .package(path: "../Lattice"),
        .package(url: "https://github.com/nicklockwood/Euclid.git",
                 branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser",
                 from: "1.0.0"),
        .package(url: "https://github.com/Velociti-Solutions/PeakOperation.git",
                 branch: "master")
    ],
    targets: [
        .executableTarget(name: "Cartographer",
                         dependencies: ["Alluvium",
                                        "Bivouac",
                                        "Deltille",
                                        "Euclid", 
                                        "Harvest",
                                        "Mercator",
                                        "PeakOperation",
                                        .product(name: "ArgumentParser",
                                                 package: "swift-argument-parser")]),
        .target(name: "Mercator",
                dependencies: ["Alluvium",
                               "Bivouac",
                               "Deltille",
                               "Euclid",
                               "Harvest",
                               "Lattice"])
    ]
)

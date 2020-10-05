// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "emceeadmin",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "emceeadmin",
            targets: [
                "EmceeAdminBinary",
            ]
        ),
    ],
    dependencies: [
        .package(name: "EmceeTestRunner", url: "https://github.com/avito-tech/Emcee.git", .branch("v11.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", .exact("5.0.1")),
    ],
    targets: [
        .target(
            name: "EasyAppKit",
            dependencies: [
                "SnapKit",
            ]
        ),
        .target(
            name: "EmceeAdminLib",
            dependencies: [
                "EasyAppKit",
                .product(name: "EmceeCommunications", package: "EmceeTestRunner"),
                .product(name: "EmceeInterfaces", package: "EmceeTestRunner"),
                "Services",
                "SnapKit",
                "TeamcityApi",
            ]
        ),
        .target(
            name: "EmceeAdminBinary",
            dependencies: [
                "EmceeAdminLib",
            ]
        ),
        .target(
            name: "Services",
            dependencies: [
                .product(name: "EmceeInterfaces", package: "EmceeTestRunner"),
            ]
        ),
        .target(
            name: "TeamcityApi",
            dependencies: []
        ),
    ]
)

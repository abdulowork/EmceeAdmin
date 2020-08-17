// swift-tools-version:5.1

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
        .package(url: "https://github.com/avito-tech/Emcee.git", .branch("master")),
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
                "EmceeCommunications",
                "EmceeInterfaces",
                "SnapKit",
                "Services",
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
            dependencies: []
        ),
        .target(
            name: "TeamcityApi",
            dependencies: []
        ),
    ]
)

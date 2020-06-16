// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "emceeadmin",
    products: [
        .executable(
            name: "emceeadmin",
            targets: []
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/avito-tech/Emcee.git", .branch("EmceeCommunications")),
    ],
    targets: [
        .target(
            name: "EmceeAdminBinary",
            dependencies: [],
        ),
    ]
)

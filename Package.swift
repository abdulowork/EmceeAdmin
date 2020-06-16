// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "emceeadmin",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(
            name: "emceeadmin",
            targets: [
                "EmceeAdminBinary",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/avito-tech/Emcee.git", .branch("EmceeCommunications")),
    ],
    targets: [
        .target(name: "EasyAppKit"),
        .target(
            name: "EmceeAdminLib",
            dependencies: [
                "EasyAppKit",
                "EmceeCommunications",
                "EmceeInterfaces",
            ]
        ),
        .target(
            name: "EmceeAdminBinary",
            dependencies: [
                "EmceeAdminLib",
            ]
        ),
    ]
)

// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIModule",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Composition", targets: ["Composition"])
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .debug)),
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Moya", package: "Moya"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Sources/Data",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .debug)),
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "Composition",
            dependencies: [
                "Domain",
                "Data",
                .product(name: "Moya", package: "Moya")
            ],
            path: "Sources/Composition",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .debug)),
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                .product(name: "Moya", package: "Moya"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Tests/DataTests",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .debug)),
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .release))
            ]
        )
    ]
)

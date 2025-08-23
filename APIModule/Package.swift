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
        .library(name: "Composition", targets: ["Composition"]),
    ],
    //  外部パッケージ依存を宣言
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3")
    ],
    // 各モジュール（ターゲット）を定義swift build
    targets: [
        // Domain層 productが依存すべき抽象（契約とモデル）（productsに公開）
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),
        // Data層 I/O実装（API/DB等）を閉じ込める内部モジュール（productsに非公開）
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Moya", package: "Moya")
            ],
            path: "Sources/Data",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"], .when(configuration: .debug))
            ]
        ),
        // Composition Dataを隠すための接続部（productsに公開）
        .target(
            name: "Composition",
            dependencies: [
                "Domain",
                "Data",
                .product(name: "Moya", package: "Moya")
            ],
            // 接続コードのみを分離し、関心の分離を明確化
            path: "Sources/Composition"
        ),
        // Data層の単体テスト
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"],
            path: "Tests/DataTests"
        )
    ]
)

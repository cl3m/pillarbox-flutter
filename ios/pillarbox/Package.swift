// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pillarbox",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "pillarbox", targets: ["pillarbox"])
    ],
    dependencies: [
        .package(url: "https://github.com/SRGSSR/pillarbox-apple", .upToNextMajor(from: "8.0.0")),    
    ],
    targets: [
        .target(
            name: "pillarbox",
            dependencies: [
                 .product(name: "PillarboxCoreBusiness", package: "pillarbox-apple"),
                 .product(name: "PillarboxPlayer", package: "pillarbox-apple"),
            ],
            resources: [
                // TODO: If your plugin requires a privacy manifest
                // (e.g. if it uses any required reason APIs), update the PrivacyInfo.xcprivacy file
                // to describe your plugin's privacy impact, and then uncomment this line.
                // For more information, see:
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),

                // TODO: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
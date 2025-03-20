// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TruvideoCapacitorCameraSdk",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "TruvideoCapacitorCameraSdk",
            targets: ["CameraPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "CameraPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/CameraPluginPlugin"),
        .testTarget(
            name: "CameraPluginPluginTests",
            dependencies: ["CameraPluginPlugin"],
            path: "ios/Tests/CameraPluginPluginTests")
    ]
)
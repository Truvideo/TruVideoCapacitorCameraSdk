// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TruvideoCapacitorCameraSdk",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "TruvideoCapacitorCameraSdk",
            targets: ["TruvideoSdkCameraPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/Truvideo/truvideo-sdk-ios-camera.git", branch: "main") 
    ],
    targets: [
        .target(
            name: "TruvideoSdkCameraPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "TruvideoSdkCamera", package: "truvideo-sdk-ios-camera")
            ],
            path: "ios/Sources/TruvideoSdkCameraPlugin"),
        .testTarget(
            name: "TruvideoSdkCameraPluginTests",
            dependencies: ["TruvideoSdkCameraPlugin"],
            path: "ios/Tests/TruvideoSdkCameraPluginTests")
    ]
)

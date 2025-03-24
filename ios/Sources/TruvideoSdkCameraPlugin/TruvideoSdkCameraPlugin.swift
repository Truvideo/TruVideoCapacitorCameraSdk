import Foundation
import Capacitor
import TruvideoSdkCamera

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TruvideoSdkCameraPlugin)
public class TruvideoSdkCameraPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "TruvideoSdkCameraPlugin"
    public let jsName = "TruvideoSdkCamera"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initCameraScreen", returnType: CAPPluginReturnPromise) // Registering initCameraScreen
    ]

    // private let implementation = TruvideoSdkCamera()

    // @objc func echo(_ call: CAPPluginCall) {
    //     let value = call.getString("value") ?? ""
    //     call.resolve([
    //         "value": implementation.echo(value)
    //     ])
    // }


 /**
     Initiates the camera functionality with specified parameters and presents the camera view.
     - Parameters:
        - viewController: The UIViewController or SwiftUIView where the camera view will be presented.
        - completion: A closure to handle the camera result upon completion.
            - cameraResult: The result of the camera operation.
     */
    @obj func initCameraScreen(viewController: UIViewController, _ completion: @escaping (_ cameraResult: TruvideoSdkCameraResult) -> Void) {
        DispatchQueue.main.async {
            // Retrieving information about the device's camera functionality.
            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
            
            // Configuring the camera with various parameters based on specific requirements.
            // - Parameter outputPath: Specifies the path for storing the captured data upon completion.
            // Additional parameters can be adjusted to customize camera behavior as needed.
            let configuration = TruvideoSdkCameraConfiguration(
                lensFacing: .back,
                flashMode: .off,
                orientation: nil,
                outputPath: "",
                frontResolutions: [],
                frontResolution: nil,
                backResolutions: [],
                backResolution: nil,
                mode: .videoAndPicture()
            )
            
            DispatchQueue.main.async {
                viewController.presentTruvideoSdkCameraView(
                    preset: configuration,
                    onComplete: { cameraResult in
                        // Handling completion of camera
                    }
                )
            }
        }
    }
}

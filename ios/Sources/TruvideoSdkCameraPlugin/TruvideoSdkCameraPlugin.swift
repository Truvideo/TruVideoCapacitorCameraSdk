import Foundation
import Capacitor
import TruvideoSdkCamera
import UIKit
import AVFoundation
import Combine

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(TruvideoSdkCameraPlugin)
public class TruvideoSdkCameraPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "TruvideoSdkCameraPlugin"
    public let jsName = "TruvideoSdkCamera"
    private var disposeBag = Set<AnyCancellable>()
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initCameraScreen", returnType: CAPPluginReturnPromise) // Registering initCameraScreen
    ]
    
    //private let implementation = TruvideoSdkCamera()
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": value
        ])
    }

    @objc func initCameraScreen(_ call: CAPPluginCall) {
        let jsonData = call.getString("configuration") ?? ""
        
        guard let data = jsonData.data(using: .utf8) else {
            print("❌ Invalid JSON string")
            call.reject("Invalid_Data", "Invalid JSON string")
            return
        }

        do {
            guard let configuration = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("❌ Invalid JSON format")
                call.reject("Invalid_JSON_Format", "Invalid JSON format")
                return
            }
            
            print("✅ Configuration parsed:", configuration)

            self.cameraInitiate(configuration: configuration) { cameraResult in
                let cameraResultDict = cameraResult.toDictionary()

                if let mediaData = cameraResultDict["media"] as? [[String: Any]] {
                    var sanitizedMediaData: [[String: Any]] = []

                    for item in mediaData {
                        var sanitizedItem: [String: Any] = [:]

                        for (key, value) in item {
                            if key == "type" {
                                sanitizedItem["type"] = ((value as AnyObject).description == "TruvideoSdkCamera.TruvideoSdkCameraMediaType.photo") ? "PICTURE" : "VIDEO"
                            }
                            if JSONSerialization.isValidJSONObject([key: value]) {
                                sanitizedItem[key] = value
                            } else if let value = value as? CustomStringConvertible {
                                sanitizedItem[key] = value.description
                            } else {
                                print("⚠️ Skipping invalid JSON value for key: \(key)")
                            }
                        }
                        sanitizedMediaData.append(sanitizedItem)
                    }

                    if let jsonData = try? JSONSerialization.data(withJSONObject: sanitizedMediaData, options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("📤 Camera Result JSON:", jsonString)
                        print("📤 Camera Result JSON:", sanitizedMediaData)
                        call.resolve(["result": sanitizedMediaData])
                    } else {
                        call.reject("Serialization_Error", "Failed to serialize camera result")
                    }
                } else {
                    call.reject("Missing_Media_Data", "Media data not found in camera result")
                }
            }
        } catch {
            print("❌ JSON Parsing Error:", error.localizedDescription)
            call.reject("Error_Parsing", "Error parsing JSON: \(error.localizedDescription)")
        }
    }


    
    /**
     Initiates the camera functionality with specified parameters and presents the camera view.
     - Parameters:
     - viewController: The UIViewController or SwiftUIView where the camera view will be presented.
     - completion: A closure to handle the camera result upon completion.
     - cameraResult: The result of the camera operation.
     */
    
    private func cameraInitiate(configuration: [String:Any], completion: @escaping (_ cameraResult: TruvideoSdkCameraResult) -> Void) {
        DispatchQueue.main.async {
//            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
//                print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
//                return
//            }
            guard let rootViewController = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene }) // Get active scenes
                .flatMap({ $0.windows }) // Get all windows
                .first(where: { $0.isKeyWindow })? // Find key window
                .rootViewController else {
                    print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
                    return
            }
            guard let lensFacingString = configuration["lensFacing"] as? String,
                  let flashModeString = configuration["flashMode"] as? String,
                  let orientationString = configuration["orientation"] as? String,
                  let outputPath = configuration["outputPath"] as? String,
                  let modeString = configuration["mode"] as? String else {
                print("Error: Missing or invalid configuration values")
                return
            }
            // Retrieving information about the device's camera functionality.
            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
            print("Camera Info:", cameraInfo)
            
            let lensType: TruvideoSdkCameraLensFacing = lensFacingString == "back" ? .back: .front
            
            let flashMode: TruvideoSdkCameraFlashMode = flashModeString == "on" ? .on: .off
            
            let orientation: TruvideoSdkCameraOrientation
            switch orientationString {
            case "portrait":
                orientation = .portrait
            case "portraitReverse":
                orientation = .portraitReverse
            case "landscapeLeft":
                orientation = .landscapeLeft
            case "landscapeRight":
                orientation = .landscapeRight
            default:
                print("Unknown orientation:", orientationString)
                return
            }
            
            let mode: TruvideoSdkCameraMediaMode
            switch modeString {
            case "picture":
                mode = .picture()
            case "video":
                mode = .video()
            case "videoAndPicture":
                mode = .videoAndPicture()
            default:
                print("Unknown mode:", modeString)
                return
            }
            
            // Configuring the camera with various parameters based on specific requirements.
            let configuration = TruvideoSdkCameraConfiguration(
                lensFacing: lensType,
                flashMode: flashMode,
                orientation: orientation,
                outputPath: outputPath,
                frontResolutions: [],
                frontResolution: nil,
                backResolutions: [],
                backResolution: nil,
                mode: mode
            )
            
            self.checkCameraPermissions { [weak self] granted in
                guard let self = self else { return }
                
                if granted {
                    DispatchQueue.main.async {
                        rootViewController.presentTruvideoSdkCameraView(
                            preset: configuration,
                            onComplete: { cameraResult in
                                print(cameraResult.toDictionary())
                                completion(cameraResult)
                            }
                        )
                    }
                } else {
                    print("Camera permission not granted")
                }
            }
        }
        
        
    }
    func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
          completion(true)
        case .notDetermined:
          AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
              completion(granted)
            }
          }
        default:
          completion(false)
        }
      }
    override public func load() {
           super.load()
           subscribeToCameraEvents()
       }
       
       private func subscribeToCameraEvents() {
           TruvideoSdkCamera.events
               .sink { [weak self] cameraEvent in
                   guard let self = self else { return }
                   let eventType = String(describing: cameraEvent.type) // Convert enum to string
                       
                   let eventData: [String: Any] = [
                        "cameraEvent": [ 
                                "type": eventType,
                                "createdAt": cameraEvent.createdAt.timeIntervalSince1970
                        ]
                    ]
                   self.notifyListeners("cameraEvent", data: eventData)
               }
               .store(in: &disposeBag)
       }
}
    
extension TruvideoSdkCameraResult {
      func toDictionary() -> [String: Any] {
        return [
          "media": media.map { $0.toDictionary() }
        ]
      }
}

extension TruvideoSdkCamera.TruvideoSdkCameraMedia {
      func toDictionary() -> [String: Any] {
        return [
          "createdAt": createdAt,
          "filePath": filePath,
          "type": type,
          "cameraLensFacing": cameraLensFacing.rawValue,
          "rotation": rotation.rawValue,
          "resolution": resolution,
          "duration": duration
        ]
      }
      
      
}

extension TruvideoSdkCamera.TruvideoSdkCameraResolution {
        func toDictionary() -> [String: Any] {
            return [:]
        }
        
        func resulDict() -> [String: Any] {
            //width: Int32, height: Int32
            return [
                "width": 0,
                "height": 0
            ]
        }
    
    
}

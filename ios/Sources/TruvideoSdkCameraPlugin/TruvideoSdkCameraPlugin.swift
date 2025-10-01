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
        CAPPluginMethod(name: "initCameraScreen", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initARCameraScreen", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initScanerScreen", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "version", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "environment", returnType: CAPPluginReturnPromise),
        
        CAPPluginMethod(name: "isAugmentedRealityInstalled", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isAugmentedRealitySupported", returnType: CAPPluginReturnPromise)
        
    ]
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": value
        ])
    }
    
    @objc func version(_ call: CAPPluginCall) {
        let version = TruvideoSdkCameraVersionNumber
        call.resolve([
            "version": version
        ])
    }
    
    @objc func environment(_ call: CAPPluginCall) {
        let environment = ""
        call.resolve([
            "environment": environment
        ])
    }
    
    @objc func isAugmentedRealityInstalled(_ call: CAPPluginCall) {
        let version = ""
        call.resolve([
            "version": version
        ])
    }
    
    @objc func isAugmentedRealitySupported(_ call: CAPPluginCall) {
        let version = ""
        call.resolve([
            "version": version
        ])
    }
    
    @objc func initCameraScreen(_ call: CAPPluginCall) {
        let jsonData = call.getString("value") ?? ""
        
        
        print(jsonData)
        
        guard let data = jsonData.data(using: .utf8) else {
            print("Invalid JSON string")
            call.reject("Invalid_Data", "Invalid JSON string", NSError(domain: "Invalid_Data", code: 400, userInfo: nil))
            return
        }
        
        do {
            if let configuration = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(configuration)
                self.cameraInitiate(configuration: configuration) { cameraResult in
                    do {
                        print("cameraResult.toDictionary()",cameraResult.toDictionary())
                        let cameraResultDict = cameraResult.toDictionary()
                        if let mediaData = cameraResultDict["media"] as? [[String: Any]] {
                            var sanitizedMediaData: [[String: Any]] = []
                            
                            for item in mediaData {
                                var sanitizedItem: [String: Any] = [:]
                                for (key, value) in item {
                                    if key == "type", let mediaType = value as? TruvideoSdkCamera.TruvideoSdkCameraMediaType {
                                        switch mediaType {
                                        case .photo:
                                            sanitizedItem["type"] = "IMAGE"
                                        case .clip:
                                            sanitizedItem["type"] = "VIDEO"
                                        default:
                                            sanitizedItem["type"] = "UNKNOWN"
                                        }
                                    } else if key == "resolution", let resolution = value as? TruvideoSdkCamera.TruvideoSdkCameraResolution {
                                        sanitizedItem["resolution"] = [
                                            "width": resolution.width,
                                            "height": resolution.height
                                        ]
                                    } else if JSONSerialization.isValidJSONObject([key: value]) {
                                        sanitizedItem[key] = value
                                    } else if let value = value as? CustomStringConvertible {
                                        sanitizedItem[key] = value.description
                                    } else {
                                        print("Skipping invalid JSON value for key: \(key)")
                                    }
                                }
                                
                                sanitizedMediaData.append(sanitizedItem)
                            }
                            
                            if let jsonData = try? JSONSerialization.data(withJSONObject: sanitizedMediaData, options: []),
                               let jsonString = String(data: jsonData, encoding: .utf8) {
                                print("📤 Camera Result JSON:", jsonString)
                                print("📤 Camera Result JSON:", sanitizedMediaData)
                                call.resolve(["value": jsonString])
                            } else {
                                call.reject("Serialization_Error", "Failed to serialize camera result")
                            }
                        }
                    } catch {
                        print("Error serializing camera result: \(error.localizedDescription)")
                        call.reject("Serialization_Error", "Error serializing camera result", error)
                    }
                }
            } else {
                print("Invalid JSON format")
                call.reject("Invalid_JSON_Format", "Invalid JSON format", NSError(domain: "Invalid_JSON_Format", code: 400, userInfo: nil))
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            call.reject("Error_parsing", "Error parsing JSON: \(error.localizedDescription)", error)
        }
    }
    
    
    
    /**
     Initiates the camera functionality with specified parameters and presents the camera view.
     - Parameters:
     - viewController: The UIViewController or SwiftUIView where the camera view will be presented.
     - completion: A closure to handle the camera result upon completion.
     - cameraResult: The result of the camera operation.
     */
    
    @objc public func initARCameraScreen(_ call: CAPPluginCall) {
        let configuration = call.getString("configuration") ?? ""
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
            return
        }
        guard let data = configuration.data(using: .utf8) else {
            print("Invalid JSON string")
            call.reject("Invalid_Data", "Invalid JSON string", NSError(domain: "Invalid_Data", code: 400, userInfo: nil))
            return
        }
        var orientation: TruvideoSdkCameraOrientation? = nil
        var mode: TruvideoSdkCameraMediaMode = .videoAndPicture()
        do{
            if let jsonConfig = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let modeString = jsonConfig["mode"] as? String;
                let orientationString = jsonConfig["orientation"] as? String;
                
                guard let data = modeString?.data(using: .utf8) else { return }
                let modeData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let mainMode  = modeData["mode"] as? String;
                let videoDurationLimit : String? = (modeData["videoDurationLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let mediaLimit : String? = (modeData["mediaLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let videoLimit : String? = (modeData["videoLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let imageLimit : String? = (modeData["imageLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            
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
                switch mainMode {
                case "videoAndImage":
                  if videoLimit != nil || imageLimit != nil {
                    mode = .videoAndPicture(
                      videoCount: videoLimit.flatMap { Int($0) },
                      pictureCount: imageLimit.flatMap { Int($0) },
                      videoDuration: videoDurationLimit.flatMap { Int($0) }
                    )
                  }else if mediaLimit != nil {
                    let mediaLimitInt = Int(mediaLimit ?? "0") ?? 0
                    mode = .videoAndPicture(
                      mediaCount: mediaLimitInt,
                      videoDuration: videoDurationLimit.flatMap { Int($0) }
                    )
                  }else {
                    mode = .videoAndPicture()
                  }
                case "video":
                  mode = .video(
                    videoCount :videoLimit.flatMap { Int($0) },
                    videoDuration: videoDurationLimit.flatMap { Int($0) }
                  )
                case "image":
                  mode = .picture(
                    pictureCount :imageLimit.flatMap { Int($0) }
                  )
                case "singleImage":
                    mode = .singlePicture()
                case "singleVideo":
                  mode = .singleVideo(
                    videoDuration : videoDurationLimit.flatMap { Int($0) }
                  )
                case "singleVideoOrImage":
                  mode = .singleVideoOrPicture(
                    videoDuration : videoDurationLimit.flatMap { Int($0) }
                  )
 
                default:
                    break
                }
            }
        }catch{
            
        }
        
        initiateARCamera(viewController: rootViewController,mode : mode, orientation : orientation){cameraResult in
            do {
                let cameraResultDict = cameraResult.toDictionary()
                if let mediaData = cameraResultDict["media"] as? [[String: Any]] {
                    var sanitizedMediaData: [[String: Any]] = []
                    
                    for item in mediaData {
                        var sanitizedItem: [String: Any] = [:]
                        for (key, value) in item {
                            if key == "type" {
                                if (value as AnyObject).description == "TruvideoSdkCamera.TruvideoSdkCameraMediaType.photo"  {
                                    sanitizedItem["type"] = "PICTURE"
                                } else {
                                    sanitizedItem["type"] = "VIDEO"
                                }
                            }
                            if JSONSerialization.isValidJSONObject([key: value]) {
                                sanitizedItem[key] = value
                            } else if let value = value as? CustomStringConvertible {
                                sanitizedItem[key] = value.description
                            } else {
                                print("Skipping invalid JSON value for key: \(key)")
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
                }
            } catch {
                print("Error serializing camera result: \(error.localizedDescription)")
                call.reject("Serialization_Error", "Error serializing camera result", error)
            }
        }
        
    }
    func initiateARCamera(viewController: UIViewController,
                          mode : TruvideoSdkCameraMediaMode,
                          orientation :TruvideoSdkCameraOrientation?,
                          completion: @escaping (_ cameraResult: TruvideoSdkCameraResult) -> Void)  {
        DispatchQueue.main.async {
            // Retrieving information about the device's camera functionality.
            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
            print("Camera Info:", cameraInfo)
            let configuration = TruvideoSdkARCameraConfiguration(flashMode: .on,mode: mode, orientation: orientation)
            DispatchQueue.main.async {
                self.subscribeToCameraEvents()
                viewController.presentTruvideoSdkARCameraView(preset: configuration, onComplete: { result in
                    //self.handle(result: result, viewController: viewController)
                    completion(result)
                })
            }
        }
    }
    
    
    @objc public func initScanerScreen(_ call: CAPPluginCall) {
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
            return
        }
        initiateScannerCamera(viewController: rootViewController){ cameraResult in
            call.resolve(["result": cameraResult.data])
        }
    }
    func initiateScannerCamera(viewController: UIViewController, _ completion: @escaping (_ cameraResult: TruvideoSdkCameraScannerCode) -> Void) {
        DispatchQueue.main.async {
            // Retrieving information about the device's camera functionality.
            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
            print("Camera Info:", cameraInfo)
            
            let configuration = TruvideoSdkScannerCameraConfiguration(flashMode: .off,orientation: .portrait,codeFormats: [.code39,.codeQR], autoClose: false,validator: .none)
            
            DispatchQueue.main.async {
                
                self.subscribeToCameraEvents()
                viewController.presentTruvideoSdkScannerCameraView(preset: configuration, onComplete: { result in
                    if let result = result{
                        completion(result)
                    }
                })
            }
        }
    }
    // Resolution parser
    func parseResolution(_ dict: [String: Any]) -> TruvideoSdkCameraResolution {
        let width = dict["width"] as? Int ?? 0
        let height = dict["height"] as? Int ?? 0
        return TruvideoSdkCameraResolution(width: Int32(width), height: Int32(height))
    }
   
    // Arrays of resolutions
    func parseResolutions(_ array: [[String: Any]]) -> [TruvideoSdkCameraResolution] {
        return array.map { parseResolution($0) }
    }
    
    private func cameraInitiate(configuration: [String:Any], completion: @escaping (_ cameraResult: TruvideoSdkCameraResult) -> Void) {
        DispatchQueue.main.async {
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
                return
            }
            guard let lensFacingString = configuration["lensFacing"] as? String,
                  let flashModeString = configuration["flashMode"] as? String,
                  let orientationString = configuration["orientation"] as? String,
                  //  let outputPath = configuration["outputPath"] as? String,
                  let outputPath = configuration["outputPath"] as? String,
                  let imageFormatString = configuration["imageFormat"] as? String,
                  let modeString = configuration["mode"] as? [String:Any] else {
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
            
            let outputPathMain = if(outputPath != ""){
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path + outputPath
            }else{
                ""
            }
            var mode: TruvideoSdkCameraMediaMode = .videoAndPicture()
            
            let imageFormat: TruvideoSdkCameraImageFormat
                        switch imageFormatString {
                        case "jpeg":
                          imageFormat = .jpeg
                        case "png":
                          imageFormat = .png
                        default:
                            print("Unknown imageFormat:", imageFormatString)
                            return
                      }
            // Front Resolutions
              let frontResolutions: [TruvideoSdkCameraResolution] = {
                  if let array = configuration["frontResolutions"] as? [[String: Any]] {
                    return self.parseResolutions(array)
                  }
                  return []
              }()
     
              let frontResolution: TruvideoSdkCameraResolution? = {
                  if let dict = configuration["frontResolution"] as? [String: Any] {
                    return self.parseResolution(dict)
                  }
                  return nil
              }()
     
              // Back Resolutions
              let backResolutions: [TruvideoSdkCameraResolution] = {
                  if let array = configuration["backResolutions"] as? [[String: Any]] {
                    return self.parseResolutions(array)
                  }
                  return []
              }()
     
              let backResolution: TruvideoSdkCameraResolution? = {
                  if let dict = configuration["backResolution"] as? [String: Any] {
                    return self.parseResolution(dict)
                  }
                  return nil
              }()
             
            
            do {
                let mainMode  = modeString["mode"] as? String;
                let videoDurationLimit : String? = (modeString["videoDurationLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let mediaLimit : String? = (modeString["mediaLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let videoLimit : String? = (modeString["videoLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let imageLimit : String? = (modeString["imageLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                switch mainMode {
                case "videoAndImage":
                  if videoLimit != nil || imageLimit != nil {
                    mode = .videoAndPicture(
                      videoCount: videoLimit.flatMap { Int($0) },
                      pictureCount: imageLimit.flatMap { Int($0) },
                      videoDuration: videoDurationLimit.flatMap { Int($0) }
                    )
                  }else if mediaLimit != nil {
                    let mediaLimitInt = Int(mediaLimit ?? "0") ?? 0
                    mode = .videoAndPicture(
                      mediaCount: mediaLimitInt,
                      videoDuration: videoDurationLimit.flatMap { Int($0) }
                    )
                  }else {
                    mode = .videoAndPicture()
                  }
                case "video":
                  mode = .video(
                    videoCount :videoLimit.flatMap { Int($0) },
                    videoDuration: videoDurationLimit.flatMap { Int($0) }
                  )
                case "image":
                  mode = .picture(
                    pictureCount :imageLimit.flatMap { Int($0) }
                  )
                case "singleImage":
                    mode = .singlePicture()
                case "singleVideo":
                  mode = .singleVideo(
                    videoDuration : videoDurationLimit.flatMap { Int($0) }
                  )
                case "singleVideoOrImage":
                  mode = .singleVideoOrPicture(
                    videoDuration : videoDurationLimit.flatMap { Int($0) }
                  )
 
                default:
                    break
                }
                
            }
            
            // Configuring the camera with various parameters based on specific requirements.
            let configuration = TruvideoSdkCameraConfiguration(
                lensFacing: lensType,
                flashMode: flashMode,
                orientation: orientation,
                outputPath: outputPathMain,
                frontResolutions: frontResolutions,
                frontResolution: frontResolution,
                backResolutions: backResolutions,
                backResolution: backResolution,
                mode: mode,
                imageFormat: imageFormat
            )
            
            self.checkCameraPermissions { [weak self] granted in
                guard self != nil else { return }
                
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
            "id" : id,
            "createdAt": createdAt,
            "filePath": filePath,
            "type": type,
            "lensFacing": lensFacing.rawValue,
            "orientation": orientation.rawValue,
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

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
        CAPPluginMethod(name: "isAugmentedRealitySupported", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getCameraInformation", returnType: CAPPluginReturnPromise)
        
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

    @objc func getCameraInformation(_ call: CAPPluginCall) {
        let cameraInfo = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
        let infoMap = convertCameraInformationToDictionary(cameraInfo)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: infoMap, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                call.reject("CAMERA_ERROR", "Failed to get camera information")
                return
            }
            call.resolve([
                "value": jsonString
            ])
        } catch {
            call.reject("CAMERA_ERROR", error.localizedDescription, error)
        }
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
                                            "width": resolution.rawValue,
                                            "height": resolution.rawValue
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
        DispatchQueue.main.async{
            let configuration = call.getString("value") ?? ""
            print("configuration====>AR:",configuration)
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                print("E_NO_ROOT_VIEW_CONTROLLER", "No root view controller found")
                return
            }
            guard let data = configuration.data(using: .utf8) else {
                print("Invalid JSON string")
                call.reject("Invalid_Data", "Invalid JSON string", NSError(domain: "Invalid_Data", code: 400, userInfo: nil))
                return
            }
            
            var flashMode: TruvideoSdkCameraFlashMode = .off
            var orientation: TruvideoSdkCameraOrientation? = nil
            var mode: TruvideoSdkCameraMediaMode = .videoAndPicture(videoCount: 100,pictureCount: 200,videoDuration: 2000000)
            
            do{
                if let jsonConfig = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let modeString = jsonConfig["mode"] as? String;
                    let orientationString = jsonConfig["orientation"] as? String;
                    let flashModeString = jsonConfig["flashMode"] as? String;
                    guard let data = modeString?.data(using: .utf8) else { return }
                    let modeData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let mainMode  = modeData["mode"] as? String;
                    let videoDurationLimit : String? = (modeData["videoDurationLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    let mediaLimit : String? = (modeData["mediaLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    let videoLimit : String? = (modeData["videoLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    let imageLimit : String? = (modeData["imageLimit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                    
                    
                    print("flashModeString ------ > ",flashModeString);
                    
                    flashMode = flashModeString == "on" ? .on: .off
                    
                    
                    if let orientationString = orientationString {
                        switch orientationString.lowercased() {
                        case "portrait":
                            orientation = .portrait
                        case "landscapeleft":
                            orientation = .landscapeLeft
                        case "landscaperight":
                            orientation = .landscapeRight
                        default:
                            orientation = nil
                        }
                    } else {
                        orientation = nil
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
                            mode = .videoAndPicture(videoCount: 100,pictureCount: 200,videoDuration: 2000000)
                            
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
                print("fail")
            }
            
            self.initiateARCamera(viewController: rootViewController,mode : mode, orientation : orientation , flashMode: flashMode){cameraResult in
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
        
    }
    func initiateARCamera(viewController: UIViewController,
                          mode : TruvideoSdkCameraMediaMode,
                          orientation :TruvideoSdkCameraOrientation?,
                          flashMode : TruvideoSdkCameraFlashMode,
                          completion: @escaping (_ cameraResult: TruvideoSdkCameraResult) -> Void)  {
        DispatchQueue.main.async {
            // Retrieving information about the device's camera functionality.
            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
            print("Camera Info:", cameraInfo)
            print(":::::flashMode::::::",flashMode.rawValue)
            let configuration = TruvideoSdkARCameraConfiguration(flashMode: flashMode,mode: mode, orientation: orientation)
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
//            let cameraInfo: TruvideoSdkCameraInformation = TruvideoSdkCamera.camera.getTruvideoSdkCameraInformation()
//            print("Camera Info:", cameraInfo)
//            
//            let configuration = TruvideoSdkScannerCameraConfiguration(flashMode: .off,orientation: .portrait,codeFormats: [.code39,.codeQR], autoClose: false,validator: .none)
//                reject("Scanner_Error", "Scanner not available in ios");
//            DispatchQueue.main.async {
//                
//                self.subscribeToCameraEvents()
//                viewController.presentTruvideoSdkScannerCameraView(preset: configuration, onComplete: { result in
//                    if let result = result{
//                        completion(result)
//                    }
//                })
//            }
        }
    }
    // Resolution parser
//    func parseResolution(_ dict: [String: Any]) -> TruvideoSdkCameraResolution {
//        let width = dict["width"] as? Int ?? 0
//        let height = dict["height"] as? Int ?? 0
////        return TruvideoSdkCameraResolution(width: Int32(width), height: Int32(height))
//        return TruvideoSdkCameraResolution(rawValue: TruvideoSdkCameraResolution.RawValue("0X0"))
//
//    }
    
    func parseResolution(_ dict: [String: Any]) -> TruvideoSdkCameraResolution {
        let width = dict["width"] as? Int ?? 0
        let height = dict["height"] as? Int ?? 0

        switch (width, height) {
        case (640, 480):
            return .sd640x480
        case (1280, 720):
            return .hd1280x720
        case (1920, 1080):
            return .hd1920x1080
        default:
            return .hd1280x720 // fallback (choose what you want)
        }
    }

   
    // Arrays of resolutions
//    func parseResolutions(_ array: [[String: Any]]) -> [TruvideoSdkCameraResolution] {
//        return array.map { parseResolution($0) }
//    }
    
    func parseResolutions(_ array: [[String: Any]]) -> [TruvideoSdkCameraResolution] {
        return array.compactMap { dict in
            let width = dict["width"] as? Int
            let height = dict["height"] as? Int
            
            guard let w = width, let h = height else { return nil }
            
            switch (w, h) {
            case (640, 480):
                return .sd640x480
            case (1280, 720):
                return .hd1280x720
            case (1920, 1080):
                return .hd1920x1080
            default:
                return nil
            }
        }
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
            
            let orientation: TruvideoSdkCameraOrientation?
            switch orientationString {
            case "portrait":
                orientation = .portrait
            case "landscapeLeft":
                orientation = .landscapeLeft
            case "landscapeRight":
                orientation = .landscapeRight
            default:
                orientation = nil
            }
            
            let outputPathMain = if(outputPath != ""){
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path + outputPath
            }else{
                ""
            }
            var mode: TruvideoSdkCameraMediaMode = .videoAndPicture()
            
            let imageFormat: TruvideoSdkCameraImageFormat
                    switch imageFormatString {
                        case "png":
                          imageFormat = .png
                        default:
                          imageFormat = .jpeg
                    }
            
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
            let configuration = TruvideoSdkCameraConfiguration(
                     backResolution: backResolution ?? .hd1920x1080,
                     backResolutions: backResolutions,
                     flashMode: flashMode,
                     frontResolution: frontResolution ?? .hd1920x1080,
                     frontResolutions: frontResolutions,
                     imageFormat: imageFormat,
                     lensFacing: lensType,
                     mode: mode,
                     orientation: orientation,
                     outputPath: outputPathMain
                 )
            
            DispatchQueue.main.async {
                rootViewController.presentTruvideoSdkCameraView(
                    preset: configuration,
                    onComplete: { cameraResult in
                        print(cameraResult.toDictionary())
                        completion(cameraResult)
                    }
                )
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

    private func convertCameraInformationToDictionary(_ information: Any) -> [String: Any] {
        var data: [String: Any] = [:]
        let mirror = Mirror(reflecting: information)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if label == "frontCamera" || label == "backCamera" {
                if let device = convertCameraDeviceToDictionary(child.value) {
                    data[label] = device
                } else {
                    data[label] = NSNull()
                }
            } else if let converted = toJsonCompatible(child.value) {
                data[label] = converted
            }
        }
        return data
    }

    private func convertCameraDeviceToDictionary(_ camera: Any) -> [String: Any]? {
        guard let unwrapped = unwrapOptional(camera) else { return nil }

        var dict: [String: Any] = [:]
        let mirror = Mirror(reflecting: unwrapped)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if let converted = toJsonCompatible(child.value) {
                dict[label] = converted
            }
        }

        // Normalize keys to match expected JS structure
        if let lens = dict["lensFacing"] as? TruvideoSdkCameraLensFacing {
            dict["lensFacing"] = convertLensToString(lensFacing: lens)
        } else if let lensAny = dict["lensFacing"], let lens = lensAny as? TruvideoSdkCameraLensFacing {
            dict["lensFacing"] = convertLensToString(lensFacing: lens)
        }

        if let resolutions = dict["resolutions"] as? [TruvideoSdkCameraResolution] {
            dict["resolutions"] = resolutions.map { convertCameraResolutionToDictionary($0) }
        }

        if dict["sensorSize"] == nil {
            dict["sensorSize"] = [
                "left": 0,
                "top": 0,
                "right": 0,
                "bottom": 0
            ]
        }

        if dict["isLogicalCamera"] == nil {
            dict["isLogicalCamera"] = false
        }

        return dict
    }

    private func convertCameraResolutionToDictionary(
        _ resolution: TruvideoSdkCameraResolution
    ) -> [String: Int] {
        let resolutionString = resolution.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = resolutionString.lowercased().split(separator: "x")

        if components.count == 2,
           let width = Int(components[0]),
           let height = Int(components[1]) {
            return [
                "width": width,
                "height": height
            ]
        }

        let (width, height) = resolutionDimensions(fromPreset: resolutionString)
        return [
            "width": width,
            "height": height
        ]
    }

    private func resolutionDimensions(fromPreset preset: String) -> (Int, Int) {
        switch preset.lowercased() {
        case "sd640x480":
            return (640, 480)
        case "hd1280x720":
            return (1280, 720)
        case "hd1920x1080":
            return (1920, 1080)
        default:
            return (0, 0)
        }
    }

    private func convertLensToString(lensFacing: TruvideoSdkCameraLensFacing) -> String {
        switch lensFacing {
        case .back:
            return "back"
        case .front:
            return "front"
        default:
            return "back"
        }
    }

    private func unwrapOptional(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle != .optional { return value }
        return mirror.children.first?.value
    }

    private func toJsonCompatible(_ value: Any) -> Any? {
        guard let unwrapped = unwrapOptional(value) else { return nil }

        if let string = unwrapped as? String { return string }
        if let bool = unwrapped as? Bool { return bool }
        if let int = unwrapped as? Int { return int }
        if let int = unwrapped as? Int32 { return Int(int) }
        if let int = unwrapped as? Int64 { return Int(int) }
        if let double = unwrapped as? Double { return double }
        if let float = unwrapped as? Float { return Double(float) }
        if let date = unwrapped as? Date { return date.timeIntervalSince1970 }
        if let size = unwrapped as? CGSize {
            return [
                "width": size.width,
                "height": size.height
            ]
        }
        if let rect = unwrapped as? CGRect {
            return [
                "left": rect.minX,
                "top": rect.minY,
                "right": rect.maxX,
                "bottom": rect.maxY
            ]
        }
        if let lens = unwrapped as? TruvideoSdkCameraLensFacing {
            return convertLensToString(lensFacing: lens)
        }
        if let resolution = unwrapped as? TruvideoSdkCameraResolution {
            return convertCameraResolutionToDictionary(resolution)
        }
        if let array = unwrapped as? [Any] {
            return array.compactMap { toJsonCompatible($0) }
        }
        if let dict = unwrapped as? [String: Any] {
            var out: [String: Any] = [:]
            for (k, v) in dict {
                if let converted = toJsonCompatible(v) {
                    out[k] = converted
                }
            }
            return out
        }
        if let dict = unwrapped as? [AnyHashable: Any] {
            var out: [String: Any] = [:]
            for (k, v) in dict {
                let key = String(describing: k)
                if let converted = toJsonCompatible(v) {
                    out[key] = converted
                }
            }
            return out
        }

        let mirror = Mirror(reflecting: unwrapped)
        if mirror.children.count > 0 {
            var out: [String: Any] = [:]
            for child in mirror.children {
                guard let label = child.label else { continue }
                if let converted = toJsonCompatible(child.value) {
                    out[label] = converted
                }
            }
            return out
        }

        return String(describing: unwrapped)
    }
    override public func load() {
        super.load()
        subscribeToCameraEvents()
    }
    
    private func subscribeToCameraEvents() {
        TruvideoSdkCamera.events
            .sink { [weak self] cameraEvent in
                guard let self = self else { return }
                let eventType = String(describing: cameraEvent.type)
                
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
        return [
            "width": 0,
            "height": 0
        ]
    }
}

import { registerPlugin } from '@capacitor/core';
import { CameraMode, FlashMode, ImageFormat, LensFacing } from './cameraConfigEnums';
const TruvideoSdkCamera = registerPlugin('TruvideoSdkCamera');
export * from './CameraConfig';
export * from './cameraConfigEnums';
function cleanObject(obj) {
    return Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== null && v !== undefined));
}
function parsePluginResponse(response, valueName = "result") {
    if (!response || typeof response !== "object") {
        throw new Error("Plugin response is not an object");
    }
    const rawValue = response[valueName];
    if (rawValue === undefined || rawValue === null) {
        throw new Error(`Plugin response.${valueName} is missing`);
    }
    // If it's already an object or boolean/number, return directly
    if (typeof rawValue === "object" || typeof rawValue === "boolean" || typeof rawValue === "number") {
        return rawValue;
    }
    if (typeof rawValue !== "string") {
        throw new Error(`Plugin response.${valueName} is not a valid string`);
    }
    try {
        return JSON.parse(rawValue);
    }
    catch {
        // If parsing fails, return the raw string
        return rawValue;
    }
}
export function initCameraScreen(configuration) {
    const cleanedConfig = cleanObject({
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        StreamingUpload: configuration.streamingUpload,
        orientation: configuration.orientation,
        outputPath: configuration.outputPath,
        defaultFrontResolution: configuration.defaultFrontResolution,
        frontResolution: configuration.frontResolutions,
        defaultBackResolution: configuration.defaultBackResolution,
        backResolution: configuration.backResolutions,
        frontResolutions: configuration.frontResolutions,
        backResolutions: configuration.backResolutions,
        mode: configuration.mode,
        imageFormat: configuration.imageFormat
    });
    return TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cleanedConfig)
    });
}
export async function initCameraScreenTS(configuration) {
    const cleanedConfig = cleanObject({
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        orientation: configuration.orientation,
        StreamingUpload: configuration.streamingUpload,
        outputPath: configuration.outputPath,
        defaultFrontResolution: configuration.defaultFrontResolution,
        frontResolution: configuration.frontResolutions,
        defaultBackResolution: configuration.defaultBackResolution,
        backResolution: configuration.backResolutions,
        frontResolutions: configuration.frontResolutions,
        backResolutions: configuration.backResolutions,
        mode: configuration.mode,
        imageFormat: configuration.imageFormat
    });
    let response = await TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cleanedConfig)
    });
    //let response = await TruvideoSdkMedia.getAllFileUploadRequests({ status : status || ''});
    //return parsePluginResponse<MediaData[]>(response,"requests");
    return parsePluginResponse(response, "value");
}
export function initARCameraScreen(configuration) {
    let data = {
        mode: configuration.mode.mode,
        videoLimit: configuration.mode.videoLimit,
        imageLimit: configuration.mode.imageLimit,
        mediaLimit: configuration.mode.mediaLimit,
        videoDurationLimit: configuration.mode.videoDurationLimit,
        autoClose: configuration.mode.autoClose,
    };
    var cameraConfiguration = {
        outputPath: configuration.outputPath,
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    };
    return TruvideoSdkCamera.initARCameraScreen({
        value: JSON.stringify(cameraConfiguration)
    });
}
export async function initARCameraScreenTS(configuration) {
    let data = {
        mode: configuration.mode.mode,
        videoLimit: configuration.mode.videoLimit,
        imageLimit: configuration.mode.imageLimit,
        mediaLimit: configuration.mode.mediaLimit,
        videoDurationLimit: configuration.mode.videoDurationLimit,
        autoClose: configuration.mode.autoClose,
    };
    var cameraConfiguration = {
        outputPath: configuration.outputPath,
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    };
    // return TruvideoSdkCamera.initARCameraScreen(
    //     JSON.stringify(cameraConfiguration)
    // );
    let response = await TruvideoSdkCamera.initARCameraScreen({
        value: JSON.stringify(cameraConfiguration)
    });
    //let response = await TruvideoSdkMedia.getAllFileUploadRequests({ status : status || ''});
    //return parsePluginResponse<MediaData[]>(response,"requests");
    return parsePluginResponse(response, "value");
}
export function initScanerScreen() {
    const cleanedConfig = cleanObject({
        lensFacing: LensFacing.Back,
        flashMode: FlashMode.Off,
        orientation: null,
        outputPath: "",
        frontResolution: "",
        backResolution: "",
        frontResolutions: [],
        backResolutions: [],
        mode: CameraMode.videoAndImage(),
        imageFormat: ImageFormat.JPEG
    });
    return TruvideoSdkCamera.initScanerScreen({
        value: JSON.stringify(cleanedConfig)
    });
}
export function version() {
    return TruvideoSdkCamera.version();
}
export function environment() {
    return TruvideoSdkCamera.environment();
}
export function isAugmentedRealityInstalled() {
    return TruvideoSdkCamera.isAugmentedRealityInstalled();
}
export function isAugmentedRealitySupported() {
    return TruvideoSdkCamera.isAugmentedRealitySupported();
}
export function requestInstallAugmentedReality() {
    return TruvideoSdkCamera.requestInstallAugmentedReality();
}
//# sourceMappingURL=index.js.map
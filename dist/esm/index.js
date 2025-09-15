import { registerPlugin } from '@capacitor/core';
const TruvideoSdkCamera = registerPlugin('TruvideoSdkCamera');
export * from './CameraConfig';
export * from './cameraConfigEnums';
function cleanObject(obj) {
    return Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== null && v !== undefined));
}
export async function initCameraScreen(configuration) {
    const cleanedConfig = cleanObject({
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        orientation: configuration.orientation,
        outputPath: configuration.outputPath,
        frontResolution: configuration.frontResolution,
        backResolution: configuration.backResolution,
        frontResolutions: configuration.frontResolutions,
        backResolutions: configuration.backResolutions,
        mode: configuration.mode,
        imageFormat: configuration.imageFormat,
    });
    return TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cleanedConfig)
    }).then((result) => {
        const parsedResult = JSON.parse(result.value);
        return { value: parsedResult };
    });
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
    return TruvideoSdkCamera.initARCameraScreen(JSON.stringify(cameraConfiguration)).then((result) => {
        const parsedResult = JSON.parse(result.value);
        return { value: parsedResult };
    });
}
export function initScanerScreen() {
    return TruvideoSdkCamera.initScanerScreen(JSON.stringify(""));
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
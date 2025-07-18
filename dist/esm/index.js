import { registerPlugin } from '@capacitor/core';
const TruvideoSdkCamera = registerPlugin('TruvideoSdkCamera');
export * from './CameraConfig';
export { TruvideoSdkCamera };
export function initCameraScreen(configuration) {
    let data = {
        mode: configuration.mode.mode,
        videoLimit: configuration.mode.videoLimit,
        imageLimit: configuration.mode.imageLimit,
        mediaLimit: configuration.mode.mediaLimit,
        videoDurationLimit: configuration.mode.videoDurationLimit,
        autoClose: configuration.mode.autoClose,
    };
    var cameraConfiguration = {
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        orientation: configuration.orientation,
        outputPath: configuration.outputPath,
        frontResolution: configuration.frontResolution,
        backResolution: configuration.backResolution,
        frontResolutions: configuration.backResolution,
        backResolutions: configuration.backResolution,
        mode: JSON.stringify(data),
    };
    return TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cameraConfiguration)
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
        mode: JSON.stringify(data),
    };
    return TruvideoSdkCamera.initARCameraScreen(JSON.stringify(cameraConfiguration));
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
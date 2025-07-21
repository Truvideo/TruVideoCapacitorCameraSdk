import { registerPlugin } from '@capacitor/core';

import type { TruvideoSdkCameraPlugin } from './definitions';
import { ARCameraConfiguration, ARConfiguration, CameraConfiguration, Configuration } from './CameraConfig';
const TruvideoSdkCamera = registerPlugin<TruvideoSdkCameraPlugin>('TruvideoSdkCamera');

export * from './CameraConfig'
export * from './cameraConfigEnums'
// export { TruvideoSdkCamera };

export function initCameraScreen(
    configuration: CameraConfiguration
): Promise<{ value: string }> {
    var cameraConfiguration: Configuration = {
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        orientation: configuration.orientation,
        outputPath: configuration.outputPath,
        frontResolution: configuration.frontResolution,
        backResolution: configuration.backResolution,
        frontResolutions: configuration.frontResolutions,
        backResolutions: configuration.backResolutions,
        mode: configuration.mode
    }
    return TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cameraConfiguration)
    });

}

export function initARCameraScreen(
    configuration: ARCameraConfiguration
): Promise<{ value: string }> {
    let data = {
        mode: configuration.mode.mode,
        videoLimit: configuration.mode.videoLimit,
        imageLimit: configuration.mode.imageLimit,
        mediaLimit: configuration.mode.mediaLimit,
        videoDurationLimit: configuration.mode.videoDurationLimit,
        autoClose: configuration.mode.autoClose,
    };
    var cameraConfiguration: ARConfiguration = {
        outputPath: configuration.outputPath,
        mode: JSON.stringify(data),
    }
    return TruvideoSdkCamera.initARCameraScreen(
        JSON.stringify(cameraConfiguration)
    );
}

export function initScanerScreen(): Promise<{ value: string }> {
    return TruvideoSdkCamera.initScanerScreen(
        JSON.stringify("")
    );
}

export function version(): Promise<string> {
    return TruvideoSdkCamera.version();
}

export function environment(): Promise<string> {
    return TruvideoSdkCamera.environment();
}
export function isAugmentedRealityInstalled(): Promise<string> {
    return TruvideoSdkCamera.isAugmentedRealityInstalled();
}
export function isAugmentedRealitySupported(): Promise<string> {
    return TruvideoSdkCamera.isAugmentedRealitySupported();
}

export function requestInstallAugmentedReality(): Promise<string> {
    return TruvideoSdkCamera.requestInstallAugmentedReality();
}

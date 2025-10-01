import { registerPlugin } from '@capacitor/core';

import type { TruvideoSdkCameraPlugin } from './definitions';
import { CameraResult} from './cameraConfigEnums';
import { ARCameraConfiguration, ARConfiguration, CameraConfiguration, Configuration } from './CameraConfig';
const TruvideoSdkCamera = registerPlugin<TruvideoSdkCameraPlugin>('TruvideoSdkCamera');

export * from './CameraConfig'
export * from './cameraConfigEnums'

function cleanObject(obj: any): any {
  return Object.fromEntries(
    Object.entries(obj).filter(([_, v]) => v !== null && v !== undefined)
  );
}
 
function parsePluginResponse<T>(response: any, valueName: string = "result"): T {
    if (!response || typeof response !== "object") {
        throw new Error("Plugin response is not an object");
    }

    const rawValue = response[valueName];

    if (rawValue === undefined || rawValue === null) {
        throw new Error(`Plugin response.${valueName} is missing`);
    }

    // If it's already an object or boolean/number, return directly
    if (typeof rawValue === "object" || typeof rawValue === "boolean" || typeof rawValue === "number") {
        return rawValue as T;
    }

    if (typeof rawValue !== "string") {
        throw new Error(`Plugin response.${valueName} is not a valid string`);
    }

    try {
        return JSON.parse(rawValue) as T;
    } catch {
        // If parsing fails, return the raw string
        return rawValue as unknown as T;
    }
}


export function initCameraScreen(
  configuration: CameraConfiguration
): Promise<{ value: string }> {
  const cleanedConfig: Configuration = cleanObject({
    lensFacing: configuration.lensFacing,
    flashMode: configuration.flashMode,
    orientation: configuration.orientation,
    outputPath: configuration.outputPath,
    frontResolution: configuration.frontResolution,
    backResolution: configuration.backResolution,
    frontResolutions: configuration.frontResolutions,
    backResolutions: configuration.backResolutions,
    mode: configuration.mode,
    imageFormat: configuration.imageFormat
  });

  return TruvideoSdkCamera.initCameraScreen({
    value: JSON.stringify(cleanedConfig)
  });
}

export async function initCameraScreenTS(
  configuration: CameraConfiguration
): Promise<CameraResult[]> {
  const cleanedConfig: Configuration = cleanObject({
    lensFacing: configuration.lensFacing,
    flashMode: configuration.flashMode,
    orientation: configuration.orientation,
    outputPath: configuration.outputPath,
    frontResolution: configuration.frontResolution,
    backResolution: configuration.backResolution,
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

  return parsePluginResponse<CameraResult[]>(response,"value");
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
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    }
    return TruvideoSdkCamera.initARCameraScreen(
        JSON.stringify(cameraConfiguration)
    );
}

export async function initARCameraScreenTS(
    configuration: ARCameraConfiguration
): Promise<CameraResult[]> {
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
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    }
    // return TruvideoSdkCamera.initARCameraScreen(
    //     JSON.stringify(cameraConfiguration)
    // );

    let response = await TruvideoSdkCamera.initARCameraScreen(
        JSON.stringify(cameraConfiguration)
    );
  //let response = await TruvideoSdkMedia.getAllFileUploadRequests({ status : status || ''});
  //return parsePluginResponse<MediaData[]>(response,"requests");

    return parsePluginResponse<CameraResult[]>(response,"value");
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

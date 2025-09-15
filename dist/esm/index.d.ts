import { ARCameraConfiguration, CameraConfiguration, CameraResult } from './CameraConfig';
export * from './CameraConfig';
export * from './cameraConfigEnums';
export declare function initCameraScreen(configuration: CameraConfiguration): Promise<{
    value: CameraResult[];
}>;
export declare function initARCameraScreen(configuration: ARCameraConfiguration): Promise<{
    value: CameraResult[];
}>;
export declare function initScanerScreen(): Promise<{
    value: string;
}>;
export declare function version(): Promise<string>;
export declare function environment(): Promise<string>;
export declare function isAugmentedRealityInstalled(): Promise<string>;
export declare function isAugmentedRealitySupported(): Promise<string>;
export declare function requestInstallAugmentedReality(): Promise<string>;

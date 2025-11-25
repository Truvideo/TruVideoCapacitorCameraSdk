export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    initARCameraScreen(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    initScanerScreen(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    version(): Promise<string>;
    environment(): Promise<string>;
    isAugmentedRealityInstalled(): Promise<string>;
    isAugmentedRealitySupported(): Promise<string>;
    requestInstallAugmentedReality(): Promise<string>;
}

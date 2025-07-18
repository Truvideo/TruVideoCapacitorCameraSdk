export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    initARCameraScreen(configuration: string): Promise<string>;
    initScanerScreen(configuration: string): Promise<string>;
    version(): Promise<string>;
    environment(): Promise<string>;
    isAugmentedRealityInstalled(): Promise<string>;
    isAugmentedRealitySupported(): Promise<string>;
    requestInstallAugmentedReality(): Promise<string>;
}

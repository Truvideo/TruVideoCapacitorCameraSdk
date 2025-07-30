import { PluginListenerHandle } from "@capacitor/core";
export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        configuration: string;
    }): Promise<{
        result: string;
    }>;
    initARCameraScreen(configuration: string): Promise<{
        value: string;
    }>;
    initScanerScreen(configuration: string): Promise<{
        value: string;
    }>;
    version(): Promise<string>;
    environment(): Promise<string>;
    isAugmentedRealityInstalled(): Promise<string>;
    isAugmentedRealitySupported(): Promise<string>;
    requestInstallAugmentedReality(): Promise<string>;
}

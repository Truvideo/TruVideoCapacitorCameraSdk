import { PluginListenerHandle } from "@capacitor/core";
export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        configuration: string;
    }): Promise<{
        result: string;
    }>;
    addListener(eventName: 'cameraEvent', listenerFunc: (event: {
        cameraEvent: {
            type: string;
            createdAt: number;
        };
    }) => void): PluginListenerHandle;
}

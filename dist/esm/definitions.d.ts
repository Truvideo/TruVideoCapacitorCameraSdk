export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}

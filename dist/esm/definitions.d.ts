import { CameraConfiguration } from "./cameraConfigInterface";
export interface TruvideoSdkCameraPlugin {
    initCameraScreen(options: {
        value: CameraConfiguration;
    }): Promise<{
        value: string;
    }>;
}

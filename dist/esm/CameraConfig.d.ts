import { LensFacing, FlashMode, Orientation, CameraMode, Resolution, ImageFormat, StreamingUpload, ResolutionPreset, Resolutions } from './cameraConfigEnums';
export interface CameraConfiguration {
    lensFacing: LensFacing;
    streamingUpload?: StreamingUpload;
    flashMode: FlashMode;
    orientation: Orientation;
    outputPath: string;
    defaultFrontResolution?: ResolutionPreset;
    frontResolutions: Resolution[];
    defaultBackResolution?: ResolutionPreset;
    backResolutions: Resolution[];
    mode: CameraMode;
    imageFormat?: ImageFormat;
}
export interface Configuration {
    lensFacing: LensFacing;
    streamingUpload?: StreamingUpload;
    flashMode: FlashMode;
    orientation: Orientation;
    outputPath: string;
    defaultFrontResolution?: ResolutionPreset;
    frontResolutions: Resolutions[];
    defaultBackResolution?: ResolutionPreset;
    backResolutions: Resolutions[];
    mode: CameraMode;
    imageFormat?: ImageFormat;
}
export interface ARCameraConfiguration {
    outputPath: string;
    orientation: Orientation;
    mode: CameraMode;
}
export interface ARConfiguration {
    outputPath: string;
    orientation: Orientation;
    mode: string;
}

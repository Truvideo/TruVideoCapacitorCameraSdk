import { LensFacing, FlashMode, Orientation, CameraMode, ImageFormat } from './cameraConfigEnums';
export interface CameraConfiguration {
    lensFacing: LensFacing;
    flashMode: FlashMode;
    orientation: Orientation;
    outputPath: string;
    frontResolutions: Resolution | null;
    frontResolution: Resolution | null;
    backResolutions: Resolution | null;
    backResolution: Resolution | null;
    mode: CameraMode;
    imageFormat?: ImageFormat;
}
export interface CameraResult {
    id: string;
    createdAt: number;
    filePath: string;
    type: CameraMediaType;
    lensFacing: LensFacing;
    orientation: Orientation;
    resolution: Resolution;
    duration: number;
}
export declare enum CameraMediaType {
    image = "IMAGE",
    video = "VIDEO"
}
export interface Configuration {
    lensFacing: LensFacing;
    flashMode: FlashMode;
    orientation: Orientation;
    outputPath: string;
    frontResolutions: Resolution | null;
    frontResolution: Resolution | null;
    backResolutions: Resolution | null;
    backResolution: Resolution | null;
    mode: CameraMode;
    imageFormat?: ImageFormat;
}
export interface Resolution {
    width: number;
    height: number;
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

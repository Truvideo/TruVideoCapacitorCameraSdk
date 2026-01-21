import { LensFacing, FlashMode, Orientation, CameraMode, Resolution, ImageFormat, StreamingUpload } from './cameraConfigEnums'

export interface CameraConfiguration {
  lensFacing: LensFacing;
  streamingUpload?: StreamingUpload;
  flashMode: FlashMode;
  orientation: Orientation;
  outputPath: string;
  frontResolutions: Resolution[];
  frontResolution: Resolution | null;
  backResolutions: Resolution[];
  backResolution: Resolution | null;
  mode: CameraMode;
  imageFormat?: ImageFormat;
};

export interface Configuration {
  lensFacing: LensFacing;
  streamingUpload?: StreamingUpload;
  flashMode: FlashMode;
  orientation: Orientation;
  outputPath: string;
  frontResolutions: Resolution[] | "";
  frontResolution: Resolution | "";
  backResolutions: Resolution[] | "";
  backResolution: Resolution | "";
  mode: CameraMode;
  imageFormat?: ImageFormat;
}

export interface ARCameraConfiguration {
  outputPath: string;
  orientation: Orientation;
  mode: CameraMode;
  flashMode?: FlashMode;
}

export interface ARConfiguration {
  outputPath: string;
  orientation: Orientation;
  mode: string;
  flashMode?: FlashMode;
}

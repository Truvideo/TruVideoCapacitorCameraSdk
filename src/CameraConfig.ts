import { LensFacing, FlashMode, Orientation, CameraMode } from './cameraConfigEnums'

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
};

export interface Configuration {
  lensFacing: LensFacing;
  flashMode: FlashMode;
  orientation: Orientation;
  outputPath: string;
  frontResolutions: Resolution | null;
  frontResolution: Resolution | null;
  backResolutions: Resolution | null;
  backResolution: Resolution | null;
  mode: string;
}

export interface Resolution {
  width: number;
  height: number;
}

export interface ARCameraConfiguration {
  outputPath: string;
  mode: CameraMode;
}

export interface ARConfiguration {
  outputPath: string;
  mode: string;
}
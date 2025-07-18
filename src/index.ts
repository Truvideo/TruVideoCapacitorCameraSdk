import { registerPlugin } from '@capacitor/core';

import type { TruvideoSdkCameraPlugin } from './definitions';
const TruvideoSdkCamera = registerPlugin<TruvideoSdkCameraPlugin>('TruvideoSdkCamera');

export * from './definitions';
export * from './CameraConfigInterface'; 
export * from './cameraConfigEnums'; 
export { TruvideoSdkCamera };
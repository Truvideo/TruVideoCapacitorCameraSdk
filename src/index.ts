import { registerPlugin } from '@capacitor/core';

import type { TruvideoSdkCameraPlugin } from './definitions';
const TruvideoSdkCamera = registerPlugin<TruvideoSdkCameraPlugin>('TruvideoSdkCamera');

export * from './definitions';
export { TruvideoSdkCamera };
import { WebPlugin } from '@capacitor/core';

import type { TruvideoSdkCameraPlugin } from './definitions';
import { CameraConfiguration } from './cameraConfigInterface';

export class TruvideoSdkCameraWeb extends WebPlugin implements TruvideoSdkCameraPlugin {
  initCameraScreen(options: { value: CameraConfiguration; }): Promise<{ value: string; }> {
    throw new Error('Method not implemented.');
  }
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

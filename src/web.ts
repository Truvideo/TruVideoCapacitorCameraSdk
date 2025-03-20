import { WebPlugin } from '@capacitor/core';

import type { CameraPluginPlugin } from './definitions';

export class CameraPluginWeb extends WebPlugin implements CameraPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

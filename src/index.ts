import { registerPlugin } from '@capacitor/core';

import type { CameraPluginPlugin } from './definitions';

const CameraPlugin = registerPlugin<CameraPluginPlugin>('CameraPlugin', {
  web: () => import('./web').then((m) => new m.CameraPluginWeb()),
});

export * from './definitions';
export { CameraPlugin };

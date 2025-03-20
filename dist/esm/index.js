import { registerPlugin } from '@capacitor/core';
const CameraPlugin = registerPlugin('CameraPlugin', {
    web: () => import('./web').then((m) => new m.CameraPluginWeb()),
});
export * from './definitions';
export { CameraPlugin };
//# sourceMappingURL=index.js.map
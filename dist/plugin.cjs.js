'use strict';

var core = require('@capacitor/core');

// import type { CameraConfiguration } from './cameraConfigInterface';
// const TruvideoSdkCamera = registerPlugin<TruvideoSdkCameraPlugin>('TruvideoSdkCamera', {
//   web: () => import('./web').then((m) => new m.TruvideoSdkCameraWeb()),
// });
const TruvideoSdkCamera = core.registerPlugin('TruvideoSdkCamera');
// const secretKey: CameraConfiguration  = {
//   lensFacing: LensFacing.Front, //Front and Back option are there
//   flashMode: FlashMode.Off,// On and Off option are there
//   orientation: Orientation.Portrait, // Portrait, LandscapeLeft,LandscapeRight and PortraitReverse option are there
//   outputPath: "file://\(outputPath)",
//   frontResolutions: [],
//   frontResolution: 'nil',
//   backResolutions: [],
//   backResolution: 'nil',
//   mode: Mode.Picture, // Picture,Video and VideoAndPicture options are there
// };
// val result = await TruvideoSdkCameraPlugin.initCameraScreen({
//   configuration: secretKey,
// });
// TruvideoSdkCameraPlugin.addListener('cameraEvent', (data) => {
//   console.log('Received event:', data);
// });

exports.TruvideoSdkCamera = TruvideoSdkCamera;
//# sourceMappingURL=plugin.cjs.js.map

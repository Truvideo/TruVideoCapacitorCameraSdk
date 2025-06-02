var capacitorTruvideoSdkCamera = (function (exports, core) {
    'use strict';

    exports.LensFacing = void 0;
    (function (LensFacing) {
        LensFacing["Back"] = "back";
        LensFacing["Front"] = "front";
    })(exports.LensFacing || (exports.LensFacing = {}));
    exports.FlashMode = void 0;
    (function (FlashMode) {
        FlashMode["Off"] = "off";
        FlashMode["On"] = "on";
    })(exports.FlashMode || (exports.FlashMode = {}));
    exports.Orientation = void 0;
    (function (Orientation) {
        Orientation["Portrait"] = "portrait";
        Orientation["LandscapeLeft"] = "landscapeLeft";
        Orientation["LandscapeRight"] = "landscapeRight";
        Orientation["PortraitReverse"] = "portraitReverse";
    })(exports.Orientation || (exports.Orientation = {}));
    exports.Mode = void 0;
    (function (Mode) {
        Mode["Video"] = "video";
        Mode["Picture"] = "picture";
        Mode["VideoAndPicture"] = "videoAndPicture";
    })(exports.Mode || (exports.Mode = {}));

    const TruvideoSdkCamera = core.registerPlugin('TruvideoSdkCamera');

    exports.TruvideoSdkCamera = TruvideoSdkCamera;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map

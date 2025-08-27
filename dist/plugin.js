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
    class CameraMode {
        constructor(mode, videoLimit, imageLimit, mediaLimit, videoDurationLimit, autoClose) {
            this.videoLimit = "";
            this.imageLimit = "";
            this.mediaLimit = "";
            this.mode = 'videoAndImage';
            this.videoDurationLimit = "";
            this.autoClose = false;
            this.mode = mode;
            this.videoLimit = videoLimit != null ? videoLimit.toString() : "";
            this.imageLimit = imageLimit != null ? imageLimit.toString() : "";
            this.mediaLimit = mediaLimit != null ? mediaLimit.toString() : "";
            this.videoDurationLimit = videoDurationLimit != null ? videoDurationLimit.toString() : "";
            this.autoClose = autoClose;
        }
        static singleMedia(durationLimit, mediaCount) {
            return new CameraMode('videoAndImage', null, null, mediaCount !== null && mediaCount !== void 0 ? mediaCount : null, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, false);
        }
        static videoAndImage(durationLimit, videoMaxCount, imageMaxCount) {
            return new CameraMode('videoAndImage', videoMaxCount !== null && videoMaxCount !== void 0 ? videoMaxCount : null, imageMaxCount !== null && imageMaxCount !== void 0 ? imageMaxCount : null, null, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, false);
        }
        getJson() {
            var data = {
                mode: this.mode,
                videoLimit: this.videoLimit,
                imageLimit: this.imageLimit,
                mediaLimit: this.mediaLimit,
                videoDurationLimit: this.videoDurationLimit,
                autoClose: this.autoClose,
            };
            return JSON.stringify(data);
        }
        static singleVideo(durationLimit) {
            return new CameraMode('singleVideo', 1, 0, null, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, true);
        }
        static singleImage() {
            return new CameraMode('singleImage', 0, 1, null, null, true);
        }
        static singleVideoOrImage(durationLimit) {
            return new CameraMode('singleVideoOrImage', null, null, 1, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, true);
        }
        static video(videoMaxCount, durationLimit) {
            return new CameraMode('video', videoMaxCount !== null && videoMaxCount !== void 0 ? videoMaxCount : null, 0, null, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, false);
        }
        static image(imageMaxCount) {
            return new CameraMode('image', 0, imageMaxCount !== null && imageMaxCount !== void 0 ? imageMaxCount : null, null, null, false);
        }
    }

    const TruvideoSdkCamera = core.registerPlugin('TruvideoSdkCamera');
    function cleanObject(obj) {
        return Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== null && v !== undefined));
    }
    function initCameraScreen(configuration) {
        const cleanedConfig = cleanObject({
            lensFacing: configuration.lensFacing,
            flashMode: configuration.flashMode,
            orientation: configuration.orientation,
            outputPath: configuration.outputPath,
            frontResolution: configuration.frontResolution,
            backResolution: configuration.backResolution,
            frontResolutions: configuration.frontResolutions,
            backResolutions: configuration.backResolutions,
            mode: configuration.mode
        });
        return TruvideoSdkCamera.initCameraScreen({
            value: JSON.stringify(cleanedConfig)
        });
    }
    function initARCameraScreen(configuration) {
        let data = {
            mode: configuration.mode.mode,
            videoLimit: configuration.mode.videoLimit,
            imageLimit: configuration.mode.imageLimit,
            mediaLimit: configuration.mode.mediaLimit,
            videoDurationLimit: configuration.mode.videoDurationLimit,
            autoClose: configuration.mode.autoClose,
        };
        var cameraConfiguration = {
            outputPath: configuration.outputPath,
            mode: JSON.stringify(data),
        };
        return TruvideoSdkCamera.initARCameraScreen(JSON.stringify(cameraConfiguration));
    }
    function initScanerScreen() {
        return TruvideoSdkCamera.initScanerScreen(JSON.stringify(""));
    }
    function version() {
        return TruvideoSdkCamera.version();
    }
    function environment() {
        return TruvideoSdkCamera.environment();
    }
    function isAugmentedRealityInstalled() {
        return TruvideoSdkCamera.isAugmentedRealityInstalled();
    }
    function isAugmentedRealitySupported() {
        return TruvideoSdkCamera.isAugmentedRealitySupported();
    }
    function requestInstallAugmentedReality() {
        return TruvideoSdkCamera.requestInstallAugmentedReality();
    }

    exports.CameraMode = CameraMode;
    exports.environment = environment;
    exports.initARCameraScreen = initARCameraScreen;
    exports.initCameraScreen = initCameraScreen;
    exports.initScanerScreen = initScanerScreen;
    exports.isAugmentedRealityInstalled = isAugmentedRealityInstalled;
    exports.isAugmentedRealitySupported = isAugmentedRealitySupported;
    exports.requestInstallAugmentedReality = requestInstallAugmentedReality;
    exports.version = version;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map

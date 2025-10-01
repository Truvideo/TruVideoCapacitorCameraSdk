'use strict';

var core = require('@capacitor/core');

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
exports.ImageFormat = void 0;
(function (ImageFormat) {
    ImageFormat["JPEG"] = "jpeg";
    ImageFormat["PNG"] = "png";
})(exports.ImageFormat || (exports.ImageFormat = {}));
exports.Orientation = void 0;
(function (Orientation) {
    Orientation["Portrait"] = "portrait";
    Orientation["LandscapeLeft"] = "landscapeLeft";
    Orientation["LandscapeRight"] = "landscapeRight";
    Orientation["PortraitReverse"] = "portraitReverse";
})(exports.Orientation || (exports.Orientation = {}));
exports.CameraMediaType = void 0;
(function (CameraMediaType) {
    CameraMediaType["image"] = "IMAGE";
    CameraMediaType["video"] = "VIDEO";
})(exports.CameraMediaType || (exports.CameraMediaType = {}));
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
    static singleMedia(mediaCount, durationLimit) {
        return new CameraMode('videoAndImage', null, null, mediaCount !== null && mediaCount !== void 0 ? mediaCount : null, durationLimit !== null && durationLimit !== void 0 ? durationLimit : null, false);
    }
    static videoAndImage(videoMaxCount, imageMaxCount, durationLimit) {
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
function parsePluginResponse(response, valueName = "result") {
    if (!response || typeof response !== "object") {
        throw new Error("Plugin response is not an object");
    }
    const rawValue = response[valueName];
    if (rawValue === undefined || rawValue === null) {
        throw new Error(`Plugin response.${valueName} is missing`);
    }
    // If it's already an object or boolean/number, return directly
    if (typeof rawValue === "object" || typeof rawValue === "boolean" || typeof rawValue === "number") {
        return rawValue;
    }
    if (typeof rawValue !== "string") {
        throw new Error(`Plugin response.${valueName} is not a valid string`);
    }
    try {
        return JSON.parse(rawValue);
    }
    catch {
        // If parsing fails, return the raw string
        return rawValue;
    }
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
        mode: configuration.mode,
        imageFormat: configuration.imageFormat
    });
    return TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cleanedConfig)
    });
}
async function initCameraScreenTS(configuration) {
    const cleanedConfig = cleanObject({
        lensFacing: configuration.lensFacing,
        flashMode: configuration.flashMode,
        orientation: configuration.orientation,
        outputPath: configuration.outputPath,
        frontResolution: configuration.frontResolution,
        backResolution: configuration.backResolution,
        frontResolutions: configuration.frontResolutions,
        backResolutions: configuration.backResolutions,
        mode: configuration.mode,
        imageFormat: configuration.imageFormat
    });
    let response = await TruvideoSdkCamera.initCameraScreen({
        value: JSON.stringify(cleanedConfig)
    });
    //let response = await TruvideoSdkMedia.getAllFileUploadRequests({ status : status || ''});
    //return parsePluginResponse<MediaData[]>(response,"requests");
    return parsePluginResponse(response, "value");
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
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    };
    return TruvideoSdkCamera.initARCameraScreen(JSON.stringify(cameraConfiguration));
}
async function initARCameraScreenTS(configuration) {
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
        orientation: configuration.orientation,
        mode: JSON.stringify(data),
    };
    // return TruvideoSdkCamera.initARCameraScreen(
    //     JSON.stringify(cameraConfiguration)
    // );
    let response = await TruvideoSdkCamera.initARCameraScreen(JSON.stringify(cameraConfiguration));
    //let response = await TruvideoSdkMedia.getAllFileUploadRequests({ status : status || ''});
    //return parsePluginResponse<MediaData[]>(response,"requests");
    return parsePluginResponse(response, "value");
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
exports.initARCameraScreenTS = initARCameraScreenTS;
exports.initCameraScreen = initCameraScreen;
exports.initCameraScreenTS = initCameraScreenTS;
exports.initScanerScreen = initScanerScreen;
exports.isAugmentedRealityInstalled = isAugmentedRealityInstalled;
exports.isAugmentedRealitySupported = isAugmentedRealitySupported;
exports.requestInstallAugmentedReality = requestInstallAugmentedReality;
exports.version = version;
//# sourceMappingURL=plugin.cjs.js.map

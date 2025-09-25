export var LensFacing;
(function (LensFacing) {
    LensFacing["Back"] = "back";
    LensFacing["Front"] = "front";
})(LensFacing || (LensFacing = {}));
export var FlashMode;
(function (FlashMode) {
    FlashMode["Off"] = "off";
    FlashMode["On"] = "on";
})(FlashMode || (FlashMode = {}));
export var ImageFormat;
(function (ImageFormat) {
    ImageFormat["JPEG"] = "jpeg";
    ImageFormat["PNG"] = "png";
})(ImageFormat || (ImageFormat = {}));
export var Orientation;
(function (Orientation) {
    Orientation["Portrait"] = "portrait";
    Orientation["LandscapeLeft"] = "landscapeLeft";
    Orientation["LandscapeRight"] = "landscapeRight";
    Orientation["PortraitReverse"] = "portraitReverse";
})(Orientation || (Orientation = {}));
export class CameraMode {
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
//# sourceMappingURL=cameraConfigEnums.js.map
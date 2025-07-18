var capacitorTruvideoSdkCamera = (function (exports, core) {
    'use strict';

    const TruvideoSdkCamera = core.registerPlugin('TruvideoSdkCamera');
    function initCameraScreen(configuration) {
        let data = {
            mode: configuration.mode.mode,
            videoLimit: configuration.mode.videoLimit,
            imageLimit: configuration.mode.imageLimit,
            mediaLimit: configuration.mode.mediaLimit,
            videoDurationLimit: configuration.mode.videoDurationLimit,
            autoClose: configuration.mode.autoClose,
        };
        var cameraConfiguration = {
            lensFacing: configuration.lensFacing,
            flashMode: configuration.flashMode,
            orientation: configuration.orientation,
            outputPath: configuration.outputPath,
            frontResolution: configuration.frontResolution,
            backResolution: configuration.backResolution,
            frontResolutions: configuration.backResolution,
            backResolutions: configuration.backResolution,
            mode: JSON.stringify(data),
        };
        return TruvideoSdkCamera.initCameraScreen({
            value: JSON.stringify(cameraConfiguration)
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

    exports.TruvideoSdkCamera = TruvideoSdkCamera;
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

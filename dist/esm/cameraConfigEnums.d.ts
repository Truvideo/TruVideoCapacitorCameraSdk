export declare enum LensFacing {
    Back = "back",
    Front = "front"
}
export declare enum FlashMode {
    Off = "off",
    On = "on"
}
export declare enum ImageFormat {
    JPEG = "jpeg",
    PNG = "png"
}
export declare enum Orientation {
    Portrait = "portrait",
    LandscapeLeft = "landscapeLeft",
    LandscapeRight = "landscapeRight",
    PortraitReverse = "portraitReverse"
}
export declare enum CameraMediaType {
    image = "IMAGE",
    video = "VIDEO"
}
export interface Resolution {
    width: number;
    height: number;
}
export interface CameraResult {
    id: string;
    createdAt: number;
    filePath: string;
    type: string;
    lensFacing: string;
    orientation: string;
    resolution: Resolution;
    duration: number;
}
export declare class CameraMode {
    videoLimit: string;
    imageLimit: string;
    mediaLimit: string;
    mode: string;
    videoDurationLimit: string;
    autoClose: boolean;
    private constructor();
    static singleMedia(mediaCount: number): CameraMode;
    static singleMedia(mediaCount: number, durationLimit?: number): CameraMode;
    static videoAndImage(): CameraMode;
    static videoAndImage(videoMaxCount?: number, imageMaxCount?: number, durationLimit?: number): CameraMode;
    getJson(): string;
    static singleVideo(): CameraMode;
    static singleVideo(durationLimit?: number): CameraMode;
    static singleImage(): CameraMode;
    static singleVideoOrImage(): CameraMode;
    static singleVideoOrImage(durationLimit?: number): CameraMode;
    static video(): CameraMode;
    static video(videoMaxCount?: number): CameraMode;
    static video(videoMaxCount?: number, durationLimit?: number): CameraMode;
    static image(): CameraMode;
    static image(imageMaxCount?: number): CameraMode;
}

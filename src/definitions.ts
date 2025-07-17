
export interface TruvideoSdkCameraPlugin {

  initCameraScreen(configuration: string): Promise<string>;
  initARCameraScreen(configuration: string): Promise<string>;
  initScanerScreen(configuration: string): Promise<string>;

  version(): Promise<string>;
  environment(): Promise<string>;
  
  isAugmentedRealityInstalled(): Promise<string>;
  isAugmentedRealitySupported(): Promise<string>;
  requestInstallAugmentedReality(): Promise<string>;
}
import {LensFacing , FlashMode, Orientation, Mode } from './cameraConfigEnums'

export interface CameraConfiguration  {
    lensFacing: LensFacing;
    flashMode: FlashMode;
    orientation: Orientation;
    outputPath: string;
    frontResolutions: string[];
    frontResolution: string;
    backResolutions: string[];
    backResolution: string;
    mode: Mode;
  };



//   const secretKey: CameraConfiguration  = {
//     lensFacing: LensFacing.Front, //Front and Back option are there
//     flashMode: FlashMode.Off,// On and Off option are there
//     orientation: Orientation.Portrait, // Portrait, LandscapeLeft,LandscapeRight and PortraitReverse option are there
//     outputPath: "file://\(outputPath)",
//     frontResolutions: [],
//     frontResolution: 'nil',
//     backResolutions: [],
//     backResolution: 'nil',
//     mode: Mode.Picture, // Picture,Video and VideoAndPicture options are there
//   };
  
  
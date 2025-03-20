import { TruvideoSdkCamera } from 'truvideo-capacitor-camera-sdk';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    TruvideoSdkCamera.echo({ value: inputValue })
}

import { CameraPlugin } from 'truvideo-capacitor-camera-sdk';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    CameraPlugin.echo({ value: inputValue })
}

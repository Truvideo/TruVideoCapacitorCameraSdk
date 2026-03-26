package com.truvideo.camera;

import android.content.Intent;
import android.util.Log;

import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.truvideo.sdk.camera.TruvideoSdkCamera;


@CapacitorPlugin(name = "TruvideoSdkCamera")
public class TruvideoSdkCameraPlugin extends Plugin implements NotifyJs {

    // private TruvideoSdkCa  mera implementation = new TruvideoSdkCamera();

    static PluginCall pluginCall;
    static Bridge mainBridge;
    static NotifyJs notifyJs;
    @PluginMethod
    public void initCameraScreen(PluginCall call){
        pluginCall = call;
        mainBridge = bridge;
        notifyJs = this;
        getContext().startActivity(new Intent(getContext(), CameraActivity.class).putExtra("from","camera").putExtra("configuration",call.getString("value")));
    }

    @PluginMethod
    public void requestInstallAugmentedReality(PluginCall call) {
        TruvideoSdkCamera.getInstance().requestInstallAugmentedReality(getActivity());
    }
    @PluginMethod
    public void initARCameraScreen(PluginCall call){
        pluginCall = call;
        mainBridge = bridge;
        notifyJs = this;
        getContext().startActivity(new Intent(getContext(), CameraActivity.class).putExtra("from","AR").putExtra("configuration",call.getString("value")));
    }

    @PluginMethod
    public void initScanerScreen(PluginCall call){
        pluginCall = call;
        mainBridge = bridge;
        notifyJs = this;
        getContext().startActivity(new Intent(getContext(), CameraActivity.class).putExtra("from","QR").putExtra("configuration",call.getString("value")));
    }

    @PluginMethod
    public void version(PluginCall call){
        String isAuth = TruvideoSdkCamera.getInstance().getVersion();
        JSObject ret = new JSObject();
        Log.i("Echo", "version");
        ret.put("version", isAuth);
        call.resolve(ret);
    }

    @PluginMethod
    public void environment(PluginCall call){
        String isAuth = TruvideoSdkCamera.getInstance().getEnvironment();
        JSObject ret = new JSObject();
        Log.i("Echo", "version");
        ret.put("environment", isAuth);
        call.resolve(ret);
    }

    @PluginMethod
    public void isAugmentedRealityInstalled(PluginCall call){
        Boolean isAuth = TruvideoSdkCamera.getInstance().isAugmentedRealityInstalled();
        JSObject ret = new JSObject();
        Log.i("Echo", "version");
        ret.put("isAugmentedRealityInstalled", isAuth);
        call.resolve(ret);
    }

    @PluginMethod
    public void isAugmentedRealitySupported(PluginCall call){
        Boolean isAuth = TruvideoSdkCamera.getInstance().isAugmentedRealitySupported();
        JSObject ret = new JSObject();
        Log.i("Echo", "version");
        ret.put("isAugmentedRealitySupported", isAuth);
        call.resolve(ret);
    }

    @Override
    public void sendEventJS(String event, JSObject object) {
        notifyListeners(event,object);
    }
}

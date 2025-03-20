package com.truvideo.camera;

import android.content.Intent;
import android.util.Log;

import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "TruvideoSdkCamera")
public class TruvideoSdkCameraPlugin extends Plugin implements NotifyJs {

    private TruvideoSdkCamera implementation = new TruvideoSdkCamera();

    static PluginCall pluginCall;
    static Bridge mainBridge;
    static NotifyJs notifyJs;
    @PluginMethod
    public void initCameraScreen(PluginCall call){
        pluginCall = call;
        mainBridge = bridge;
        notifyJs = this;
        Log.d("initCameraScreen","initCameraScreen");
        getContext().startActivity(new Intent(getContext(), CameraActivity.class).putExtra("configuration",call.getString("configuration")));
    }


    @Override
    public void sendEventJS(String event, JSObject object) {
        notifyListeners(event,object);
    }
}

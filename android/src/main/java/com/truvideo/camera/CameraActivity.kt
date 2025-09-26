package com.truvideo.camera

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import com.getcapacitor.JSObject
import com.truvideo.camera.ui.theme.AndroidTheme
import com.truvideo.sdk.camera.TruvideoSdkCamera
import com.truvideo.sdk.camera.model.TruvideoSdkCameraConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraEvent
import com.truvideo.sdk.camera.model.TruvideoSdkCameraFlashMode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraLensFacing
import com.truvideo.sdk.camera.model.TruvideoSdkCameraMode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraOrientation
import com.truvideo.sdk.camera.model.TruvideoSdkCameraResolution
import com.truvideo.sdk.camera.ui.activities.camera.TruvideoSdkCameraContract
import org.json.JSONObject
import com.google.gson.Gson
import com.truvideo.sdk.camera.interfaces.TruvideoSdkCameraScannerValidation
import com.truvideo.sdk.camera.model.TruvideoSdkArCameraConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerCode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerValidationResult
import com.truvideo.sdk.camera.ui.activities.arcamera.TruvideoSdkArCameraContract
import com.truvideo.sdk.camera.ui.activities.scanner.TruvideoSdkCameraScannerContract

class CameraActivity : ComponentActivity() {
    var configuration = ""
    var lensFacing = TruvideoSdkCameraLensFacing.BACK
    var flashMode = TruvideoSdkCameraFlashMode.OFF
    var orientation: TruvideoSdkCameraOrientation? = null
    var mode = TruvideoSdkCameraMode.videoAndImage()
    var from = ""
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AndroidTheme {}
        }
        getEvent()
        getIntentData()
        if(from.equals("camera",true)){
            startCamera()
        }else if(from.equals("AR",true)){
            startAR()
        }else if(from.equals("QR",false)){
            startQR()
        }
    }

    fun startCamera(){
        val cameraScreen = registerForActivityResult(TruvideoSdkCameraContract()){
            // value
            val ret = JSObject()
            ret.put("value",Gson().toJson(it))
            TruvideoSdkCameraPlugin.pluginCall.resolve(ret)
            finish()
        }
        openCamera(this@CameraActivity,cameraScreen)
    }
    fun getEvent(){
        TruvideoSdkCamera.events.observeForever{event : TruvideoSdkCameraEvent ->
            sendEvent(eventName = "cameraEvent",event)
        }
    }
    fun sendEvent(eventName: String, eventData: TruvideoSdkCameraEvent) {
        TruvideoSdkCameraPlugin.mainBridge?.let {
            it.webView.post {
                TruvideoSdkCameraPlugin.notifyJs.sendEventJS(eventName, com.getcapacitor.JSObject().apply {
                    put("cameraEvent", Gson().toJson(eventData))
                })
            }
        }
    }
    fun getIntentData(){
        if(intent.hasExtra("configuration")){
            configuration = intent.getStringExtra("configuration")!!
        }
        if(intent.hasExtra("from")){
            from = intent.getStringExtra("from")!!
        }
    }

    fun startAR(){
        var arScreen = registerForActivityResult(TruvideoSdkArCameraContract()){
            val ret = JSObject()
            ret.put("value",Gson().toJson(it))
            TruvideoSdkCameraPlugin.pluginCall.resolve(ret)
            finish()
        }
        val jsonConfiguration = JSONObject(configuration)
        if(jsonConfiguration.has("orientation")) {
            when(jsonConfiguration.getString("orientation")){
                "portrait" -> orientation = TruvideoSdkCameraOrientation.PORTRAIT
                "landscapeLeft" -> orientation = TruvideoSdkCameraOrientation.LANDSCAPE_LEFT
                "landscapeRight" -> orientation = TruvideoSdkCameraOrientation.LANDSCAPE_RIGHT
                "portraitReverse" -> orientation = TruvideoSdkCameraOrientation.PORTRAIT_REVERSE
            }
        }
        if(jsonConfiguration.has("mode")){
            val jsonMode = JSONObject(jsonConfiguration.getString("mode"))
            val videoDurationLimit : String? = if(jsonMode.getString("videoDurationLimit") != "" ) jsonMode.getString("videoDurationLimit") else null
            val mediaLimit : String? = if(jsonMode.getString("mediaLimit") != "" ) jsonMode.getString("mediaLimit") else null
            val videoLimit : String? = if(jsonMode.getString("videoLimit") != "" ) jsonMode.getString("videoLimit") else null
            val imageLimit : String? = if(jsonMode.getString("imageLimit") != "" ) jsonMode.getString("imageLimit") else null
            when(jsonMode.getString("mode")) {
                "videoAndImage" -> {
                    mode = if(imageLimit != null || videoLimit != null){
                        TruvideoSdkCameraMode.videoAndImage(
                            imageMaxCount = imageLimit?.toInt(),
                            videoMaxCount = videoLimit?.toInt(),
                            durationLimit = videoDurationLimit?.toDouble()
                        )
                    }else if(mediaLimit != null){
                        TruvideoSdkCameraMode.videoAndImage(
                            maxCount = mediaLimit.toInt(),
                            durationLimit = videoDurationLimit?.toDouble()
                        )
                    }else {
                        TruvideoSdkCameraMode.videoAndImage()
                    }
                }
                "video" -> {
                    mode = TruvideoSdkCameraMode.video(
                        maxCount = videoLimit?.toInt(),
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
                "image" -> {
                    mode = TruvideoSdkCameraMode.image(
                        maxCount = imageLimit?.toInt()
                    )
                }
                "singleImage" ->{
                    mode = TruvideoSdkCameraMode.singleImage()
                }
                "singleVideo" ->{
                    mode = TruvideoSdkCameraMode.singleVideo(
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
                "singleVideoOrImage" -> {
                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
            }
        }
        arScreen.launch(TruvideoSdkArCameraConfiguration(
            outputPath = this@CameraActivity.filesDir.path + "/camera"  ,
            orientation = orientation,
            mode = mode
        ))
    }

    fun startQR(){
        var qrScreen = registerForActivityResult(TruvideoSdkCameraScannerContract()){
            val ret = JSObject()
            ret.put("value",it!!.data)
            TruvideoSdkCameraPlugin.pluginCall.resolve(ret)
            finish()
        }
        qrScreen.launch(
            TruvideoSdkCameraScannerConfiguration(
                validator = object : TruvideoSdkCameraScannerValidation{
                    override fun validate(code: TruvideoSdkCameraScannerCode): TruvideoSdkCameraScannerValidationResult {
                        return TruvideoSdkCameraScannerValidationResult.success()
                    }
                }
            )
        )
    }

    private fun openCamera(context: Context, cameraScreen: ActivityResultLauncher<TruvideoSdkCameraConfiguration>?) {
        // Start camera with configuration
        // if camera is not available, it will return null
        if (cameraScreen == null) return
        // Get camera information
        val cameraInfo = TruvideoSdkCamera.getInformation()

        var outputPath = context.filesDir.path + "/camera"
        val jsonConfiguration = JSONObject(configuration)
        if(jsonConfiguration.has("outputPath")){
            val newOutputPath = jsonConfiguration.getString("outputPath")
            if(newOutputPath.isNotEmpty()){
                outputPath = newOutputPath
            }
        }
        var frontResolutions: List<TruvideoSdkCameraResolution> = ArrayList()
        if (cameraInfo.frontCamera != null) {
            // if you don't want to decide the list of allowed resolutions, you can s1end all the resolutions or an empty list
            frontResolutions = cameraInfo.frontCamera!!.resolutions
        }


        // You can decide the default resolution for the front camera
        var frontResolution: TruvideoSdkCameraResolution? = null
        if (cameraInfo.frontCamera != null) {
            // Example of how tho pick the first resolution as the default one
            val resolutions = cameraInfo.frontCamera!!.resolutions
            if (resolutions.isNotEmpty()) {
                frontResolution = resolutions[0]
            }
        }
        val backResolutions: List<TruvideoSdkCameraResolution> = ArrayList()
        val backResolution: TruvideoSdkCameraResolution? = null
        checkConfigure()
        val configuration = TruvideoSdkCameraConfiguration(
            lensFacing = lensFacing,
            flashMode = flashMode,
            orientation = orientation,
            outputPath = outputPath,
            frontResolutions = frontResolutions,
            frontResolution = frontResolution,
            backResolutions = backResolutions,
            backResolution = backResolution,
            mode = mode
        )

        cameraScreen.launch(configuration)

    }

    private fun checkConfigure() {
        val jsonConfiguration = JSONObject(configuration)
        if (jsonConfiguration.has("lensFacing")) {
            when (jsonConfiguration.getString("lensFacing")) {
                "back" -> lensFacing = TruvideoSdkCameraLensFacing.BACK
                "front" -> lensFacing = TruvideoSdkCameraLensFacing.FRONT
            }
        }
        if(jsonConfiguration.has("flashMode")) {
            when (jsonConfiguration.getString("flashMode")) {
                "on" -> flashMode = TruvideoSdkCameraFlashMode.ON
                "off" -> flashMode = TruvideoSdkCameraFlashMode.OFF

            }
        }
        if(jsonConfiguration.has("orientation")) {
            when(jsonConfiguration.getString("orientation")){
                "portrait" -> orientation = TruvideoSdkCameraOrientation.PORTRAIT
                "landscapeLeft" -> orientation = TruvideoSdkCameraOrientation.LANDSCAPE_LEFT
                "landscapeRight" -> orientation = TruvideoSdkCameraOrientation.LANDSCAPE_RIGHT
                "portraitReverse" -> orientation = TruvideoSdkCameraOrientation.PORTRAIT_REVERSE
            }
        }
        if(jsonConfiguration.has("mode")){
            val jsonMode = JSONObject(jsonConfiguration.getString("mode"))
            val videoDurationLimit : String? = if(jsonMode.getString("videoDurationLimit") != "" ) jsonMode.getString("videoDurationLimit") else null
            val mediaLimit : String? = if(jsonMode.getString("mediaLimit") != "" ) jsonMode.getString("mediaLimit") else null
            val videoLimit : String? = if(jsonMode.getString("videoLimit") != "" ) jsonMode.getString("videoLimit") else null
            val imageLimit : String? = if(jsonMode.getString("imageLimit") != "" ) jsonMode.getString("imageLimit") else null
            when(jsonMode.getString("mode")) {
                "videoAndImage" -> {
                    if(imageLimit != null || videoLimit != null){
                        mode = TruvideoSdkCameraMode.videoAndImage(
                            imageMaxCount = imageLimit?.toInt(),
                            videoMaxCount = videoLimit?.toInt(),
                            durationLimit = videoDurationLimit?.toDouble()
                        )
                    }else if(mediaLimit != null){
                        mode = TruvideoSdkCameraMode.videoAndImage(
                            maxCount = mediaLimit.toInt(),
                            durationLimit = videoDurationLimit?.toDouble()
                        )
                    }else {
                        mode = TruvideoSdkCameraMode.videoAndImage()
                    }
                }
                "video" -> {
                    mode = TruvideoSdkCameraMode.video(
                        maxCount = videoLimit?.toInt(),
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
                "image" -> {
                    mode = TruvideoSdkCameraMode.image(
                        maxCount = imageLimit?.toInt()
                    )
                }
                "singleImage" ->{
                    mode = TruvideoSdkCameraMode.singleImage()
                }
                "singleVideo" ->{
                    mode = TruvideoSdkCameraMode.singleVideo(
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
                "singleVideoOrImage" -> {
                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
                        durationLimit = videoDurationLimit?.toDouble()
                    )
                }
            }
        }
    }
}

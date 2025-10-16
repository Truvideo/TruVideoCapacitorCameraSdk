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
import com.truvideo.sdk.camera.model.TruvideoSdkCameraImageFormat
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerCode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerValidationResult
import com.truvideo.sdk.camera.ui.activities.arcamera.TruvideoSdkArCameraContract
import com.truvideo.sdk.camera.ui.activities.scanner.TruvideoSdkCameraScannerContract
import org.json.JSONArray

class CameraActivity : ComponentActivity() {
    private var configuration = ""
    private var lensFacing = TruvideoSdkCameraLensFacing.BACK
    private var flashMode = TruvideoSdkCameraFlashMode.OFF
    private var orientation: TruvideoSdkCameraOrientation? = null
    private var mode = TruvideoSdkCameraMode.videoAndImage()
    private var from = ""
    private var imageFormat = TruvideoSdkCameraImageFormat.JPEG
    private var videoStabilizationEnabled = true
    private var frontResolutions : List<TruvideoSdkCameraResolution> = listOf()
    private var frontResolution : TruvideoSdkCameraResolution? = null
    private var backResolutions : List<TruvideoSdkCameraResolution> = listOf()
    private var backResolution : TruvideoSdkCameraResolution? = null
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

    // Single Resolution Parser
    fun parseResolution(obj: JSONObject): TruvideoSdkCameraResolution {
        val width = obj.optInt("width", 0)
        val height = obj.optInt("height", 0)
        return TruvideoSdkCameraResolution(width, height) // Assume Resolution(width, height) is your model
    }

    // Array of Resolutions
    fun parseResolutions(array: JSONArray): List<TruvideoSdkCameraResolution> {
        val list = mutableListOf<TruvideoSdkCameraResolution>()
        for (i in 0 until array.length()) {
            val resObj = array.getJSONObject(i)
            list.add(parseResolution(resObj))
        }
        return list
    }
    fun startAR(){
        val arScreen = registerForActivityResult(TruvideoSdkArCameraContract()){
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
                            durationLimit = videoDurationLimit?.toInt()
                        )
                    }else if(mediaLimit != null){
                        TruvideoSdkCameraMode.videoAndImage(
                            maxCount = mediaLimit.toInt(),
                            durationLimit = videoDurationLimit?.toInt()
                        )
                    }else {
                        TruvideoSdkCameraMode.videoAndImage()
                    }
                }
                "video" -> {
                    mode = TruvideoSdkCameraMode.video(
                        maxCount = videoLimit?.toInt(),
                        durationLimit = videoDurationLimit?.toInt()
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
                        durationLimit = videoDurationLimit?.toInt()
                    )
                }
                "singleVideoOrImage" -> {
                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
                        durationLimit = videoDurationLimit?.toInt()
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
        val qrScreen = registerForActivityResult(TruvideoSdkCameraScannerContract()){
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
        var outputPath = context.filesDir.path + "/camera"
        val jsonConfiguration = JSONObject(configuration)
        if(jsonConfiguration.has("outputPath")){
            val newOutputPath = jsonConfiguration.getString("outputPath")
            if(newOutputPath.isNotEmpty()){
                outputPath = context.filesDir.path + newOutputPath
            }
        }
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
            mode = mode,
            imageFormat = imageFormat,
            videoStabilizationEnabled = videoStabilizationEnabled
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

        // Front Resolutions
        if (jsonConfiguration.has("frontResolutions")) {
            frontResolutions = parseResolutions(jsonConfiguration.getJSONArray("frontResolutions"))
        }
        if (jsonConfiguration.has("frontResolution")) {
            frontResolution = parseResolution(jsonConfiguration.getJSONObject("frontResolution"))
        }

// Back Resolutions
        if (jsonConfiguration.has("backResolutions")) {
            backResolutions = parseResolutions(jsonConfiguration.getJSONArray("backResolutions"))
        }
        if (jsonConfiguration.has("backResolution")) {
            backResolution = parseResolution(jsonConfiguration.getJSONObject("backResolution"))
        }

        if(jsonConfiguration.has("imageFormat")) {
            when(jsonConfiguration.getString("imageFormat")){
                "jpeg" -> imageFormat = TruvideoSdkCameraImageFormat.JPEG
                "png" -> imageFormat = TruvideoSdkCameraImageFormat.PNG
            }
        }

        if(jsonConfiguration.has("videoStabilizationEnabled")) {
            when(jsonConfiguration.getString("videoStabilizationEnabled")){
                "true" -> videoStabilizationEnabled = true
                "false" -> videoStabilizationEnabled = false
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
                            durationLimit = videoDurationLimit?.toInt()
                        )
                    }else if(mediaLimit != null){
                        mode = TruvideoSdkCameraMode.videoAndImage(
                            maxCount = mediaLimit.toInt(),
                            durationLimit = videoDurationLimit?.toInt()
                        )
                    }else {
                        mode = TruvideoSdkCameraMode.videoAndImage()
                    }
                }
                "video" -> {
                    mode = TruvideoSdkCameraMode.video(
                        maxCount = videoLimit?.toInt(),
                        durationLimit = videoDurationLimit?.toInt()
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
                        durationLimit = videoDurationLimit?.toInt()
                    )
                }
                "singleVideoOrImage" -> {
                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
                        durationLimit = videoDurationLimit?.toInt()
                    )
                }
            }
        }
    }
}

package com.truvideo.camera

import android.content.Context
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.getcapacitor.JSObject
import com.getcapacitor.plugin.util.HttpRequestHandler.request
import com.google.gson.Gson
import com.truvideo.sdk.camera.TruvideoSdkCamera
import com.truvideo.sdk.camera.interfaces.TruvideoSdkCameraScannerValidation
import com.truvideo.sdk.camera.model.TruvideoSdkArCameraConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraFlashMode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraImageFormat
import com.truvideo.sdk.camera.model.TruvideoSdkCameraLensFacing
import com.truvideo.sdk.camera.model.TruvideoSdkCameraMedia
import com.truvideo.sdk.camera.model.TruvideoSdkCameraOrientation
import com.truvideo.sdk.camera.model.TruvideoSdkCameraResolution
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerCode
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerConfiguration
import com.truvideo.sdk.camera.model.TruvideoSdkCameraScannerValidationResult
import com.truvideo.sdk.camera.model.external.TruvideoSdkCameraConfiguration
import com.truvideo.sdk.camera.model.external.TruvideoSdkCameraEvent
import com.truvideo.sdk.camera.model.external.TruvideoSdkCameraMode
import com.truvideo.sdk.camera.ui.activities.arcamera.TruvideoSdkArCameraContract
import com.truvideo.sdk.camera.ui.activities.camera.TruvideoSdkCameraContract
import com.truvideo.sdk.camera.ui.activities.scanner.TruvideoSdkCameraScannerContract
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject


class CameraActivity : ComponentActivity() {
    private var configuration = ""
    private var lensFacing = TruvideoSdkCameraLensFacing.BACK
    private var flashMode = TruvideoSdkCameraFlashMode.OFF
    private var streamingUpload = false
    private var orientation: TruvideoSdkCameraOrientation? = null
    private var mode : TruvideoSdkCameraMode = TruvideoSdkCameraMode.VideoAndImage()
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
        getEvent()
        if(intent.hasExtra("from")){
            from = intent.getStringExtra("from")!!
        }
        if(from.equals("camera",true)){
            getIntentData()
            startCamera()
        }else if(from.equals("AR",true)){
            getIntentData()
            startAR()
        }else if(from.equals("QR",false)){
            startQR()
        }else if(from.equals("getCameraInformation", true)){
            getCameraInformation()
        }
    }

    fun startCamera(){
        val cameraScreen = registerForActivityResult(TruvideoSdkCameraContract()){
            // value
            val ret = JSObject()
            ret.put("value",cameraResults(it))
            TruvideoSdkCameraPlugin.pluginCall.resolve(ret)
            finish()
        }
        openCamera(this@CameraActivity,cameraScreen)
    }

    fun cameraResults(result : List<TruvideoSdkCameraMedia>) : String{
        val array = JSONArray()
        for (r in result) {
            val jsonString: String = cameraResult(r)
            try {
                array.put(JSONObject(jsonString))
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
        return array.toString()
    }
    fun cameraResult(result : TruvideoSdkCameraMedia) : String{
        val map: MutableMap<String, Any> = HashMap<String, Any>()
        map["id"] = result.id
        map["createdAt"] = result.createdAt
        map["filePath"] = result.filePath
        map["type"] = result.type.name
        map["lensFacing"] = result.lensFacing.name
        map["orientation"] = result.orientation.name
        map["resolution"] = result.resolution
        map["duration"] = result.duration/1000
        return Gson().toJson(map)
    }
    fun getEvent(){
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                TruvideoSdkCamera.events.collect { event ->
//                    val gson = Gson()
//                    val eventData = mapOf(
//                        "type" to event.eventType.name,
//                        "data" to event.data,
//                    )
//                    val jsonResult = gson.toJson(eventData)
//                    TruvideoCameraSdkPlugin.sendEvent(jsonResult)
                    sendEvent(eventName = "cameraEvent",event)
                }
            }
        }
//        TruvideoSdkCamera.events.observeForever{event : TruvideoSdkCameraEvent ->
//            sendEvent(eventName = "cameraEvent",event)
//        }
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
                "videoAndImage" -> when {
                    videoDurationLimit != null && mediaLimit != null ->
                        TruvideoSdkCameraMode.VideoAndImage(
                            limit = TruvideoSdkCameraMode.VideoAndImage.Limit.ByTotal(
                                maxMediaCount = mediaLimit.toInt()
                            ),
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    videoDurationLimit != null && videoLimit != null && imageLimit != null ->
                        TruvideoSdkCameraMode.VideoAndImage(
                            limit = TruvideoSdkCameraMode.VideoAndImage.Limit.ByType(
                                maxImageCount = imageLimit.toInt(),
                                maxVideoCount = videoLimit.toInt()
                            ),
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    videoDurationLimit != null ->
                        TruvideoSdkCameraMode.VideoAndImage(
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    else -> TruvideoSdkCameraMode.VideoAndImage()
                }

                "video" -> TruvideoSdkCameraMode.Video(
                    maxCount = videoLimit!!.toInt(),
                    durationLimit = videoDurationLimit!!.toLong()*1000
                )

                "image" -> TruvideoSdkCameraMode.Image(
                    maxCount = imageLimit!!.toInt()
                )

                "singleImage" ->
                    TruvideoSdkCameraMode.SingleImage(autoClose = true)

                "singleVideo" ->
                    TruvideoSdkCameraMode.SingleVideo(
                        durationLimit = videoDurationLimit!!.toLong()*1000,
                        autoClose = true
                    )

                "singleVideoOrImage" ->
                    TruvideoSdkCameraMode.SingleVideoOrImage(
                        videoDurationLimit = videoDurationLimit!!.toLong()*1000,
                        autoClose = true
                    )

                else -> mode
//                "videoAndImage" -> {
//                    mode = if(imageLimit != null || videoLimit != null){
//                        TruvideoSdkCameraMode.VideoAndImage(
//                            imageMaxCount = imageLimit?.toInt(),
//                            videoMaxCount = videoLimit?.toInt(),
//                            durationLimit = videoDurationLimit?.toInt()
//                        )
//                    }else if(mediaLimit != null){
//                        TruvideoSdkCameraMode.videoAndImage(
//                            maxCount = mediaLimit.toInt(),
//                            durationLimit = videoDurationLimit?.toInt()
//                        )
//                    }else {
//                        TruvideoSdkCameraMode.videoAndImage()
//                    }
//                }
//                "video" -> {
//                    mode = TruvideoSdkCameraMode.video(
//                        maxCount = videoLimit?.toInt(),
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
//                "image" -> {
//                    mode = TruvideoSdkCameraMode.image(
//                        maxCount = imageLimit?.toInt()
//                    )
//                }
//                "singleImage" ->{
//                    mode = TruvideoSdkCameraMode.singleImage()
//                }
//                "singleVideo" ->{
//                    mode = TruvideoSdkCameraMode.singleVideo(
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
//                "singleVideoOrImage" -> {
//                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
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
            ret.put("value",it?.data ?: "")
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
            streamingUpload = streamingUpload,
            imageFormat = imageFormat,
            videoStabilizationEnabled = videoStabilizationEnabled
        )

        Log.d("configuration_tag","$configuration")
        cameraScreen.launch(configuration)

    }

    private fun checkConfigure() {
        val jsonConfiguration = JSONObject(configuration)

        if (jsonConfiguration.has("streamingUpload")) {
            when (jsonConfiguration.getString("streamingUpload")) {
                "on" -> streamingUpload = true
                "off" -> streamingUpload = false
            }
        }

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
        if (jsonConfiguration.has("frontResolutions") &&
            jsonConfiguration.getString("frontResolutions").isNotEmpty() &&
            jsonConfiguration.getString("frontResolutions") != "[]") {

            frontResolutions = parseResolutions(jsonConfiguration.getJSONArray("frontResolutions"))
        }
        if (jsonConfiguration.has("frontResolution") &&
            jsonConfiguration.getString("frontResolution").isNotEmpty()) {
            frontResolution = parseResolution(jsonConfiguration.getJSONObject("frontResolution"))
        }

        // Back Resolutions
        if (jsonConfiguration.has("backResolutions")&&
            jsonConfiguration.getString("backResolutions").isNotEmpty() &&
            jsonConfiguration.getString("backResolutions") != "[]") {
            backResolutions = parseResolutions(jsonConfiguration.getJSONArray("backResolutions"))
        }
        if (jsonConfiguration.has("backResolution") &&
            jsonConfiguration.getString("backResolution").isNotEmpty()) {
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
                "videoAndImage" -> when {
                    videoDurationLimit != null && mediaLimit != null ->
                        mode = TruvideoSdkCameraMode.VideoAndImage(
                            limit = TruvideoSdkCameraMode.VideoAndImage.Limit.ByTotal(
                                maxMediaCount = mediaLimit.toInt()
                            ),
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    videoDurationLimit != null && videoLimit != null && imageLimit != null ->
                        mode = TruvideoSdkCameraMode.VideoAndImage(
                            limit = TruvideoSdkCameraMode.VideoAndImage.Limit.ByType(
                                maxImageCount = imageLimit.toInt(),
                                maxVideoCount = videoLimit.toInt()
                            ),
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    videoDurationLimit != null ->
                        mode = TruvideoSdkCameraMode.VideoAndImage(
                            videoDurationLimit = videoDurationLimit.toLong()*1000
                        )

                    else -> mode = TruvideoSdkCameraMode.VideoAndImage()
                }

                "video" -> mode = TruvideoSdkCameraMode.Video(
                    maxCount = videoLimit?.toInt(),
                    durationLimit = if(videoDurationLimit != null) { videoDurationLimit.toLong()*1000
                        }else { 0.toLong() }
                )

                "image" -> mode = TruvideoSdkCameraMode.Image(
                    maxCount = imageLimit?.toInt()
                )

                "singleImage" ->
                    mode = TruvideoSdkCameraMode.SingleImage(autoClose = true)

                "singleVideo" ->
                    mode = TruvideoSdkCameraMode.SingleVideo(
                        durationLimit = if(videoDurationLimit != null) {
                            videoDurationLimit.toLong()*1000
                        }else
                        {
                            0.toLong()
                        },
                        autoClose = true
                    )

                "singleVideoOrImage" -> {
                    if(videoDurationLimit == null){
                        mode = TruvideoSdkCameraMode.SingleVideoOrImage(
                            autoClose = true
                        )
                    }else{
                        mode = TruvideoSdkCameraMode.SingleVideoOrImage(
                            videoDurationLimit = videoDurationLimit.toLong()*1000,
                            autoClose = true
                        )
                    }


                }


                else -> mode
//                "videoAndImage" -> {
//                    if(imageLimit != null || videoLimit != null){
//                        mode = TruvideoSdkCameraMode.videoAndImage(
//                            imageMaxCount = imageLimit?.toInt(),
//                            videoMaxCount = videoLimit?.toInt(),
//                            durationLimit = videoDurationLimit?.toInt()
//                        )
//                    }else if(mediaLimit != null){
//                        mode = TruvideoSdkCameraMode.videoAndImage(
//                            maxCount = mediaLimit.toInt(),
//                            durationLimit = videoDurationLimit?.toInt()
//                        )
//                    }else {
//                        mode = TruvideoSdkCameraMode.videoAndImage()
//                    }
//                }
//                "video" -> {
//                    mode = TruvideoSdkCameraMode.video(
//                        maxCount = videoLimit?.toInt(),
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
//                "image" -> {
//                    mode = TruvideoSdkCameraMode.image(
//                        maxCount = imageLimit?.toInt()
//                    )
//                }
//                "singleImage" ->{
//                    mode = TruvideoSdkCameraMode.singleImage()
//                }
//                "singleVideo" ->{
//                    mode = TruvideoSdkCameraMode.singleVideo(
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
//                "singleVideoOrImage" -> {
//                    mode = TruvideoSdkCameraMode.singleVideoOrImage(
//                        durationLimit = videoDurationLimit?.toInt()
//                    )
//                }
            }
        }
    }

    private fun getCameraInformation() {
        try {
            val info = TruvideoSdkCamera.getInformation()
            val ret = JSObject()
            ret.put("value", info.toJson())
            TruvideoSdkCameraPlugin.pluginCall.resolve(ret)
        } catch (e: Exception) {
            TruvideoSdkCameraPlugin.pluginCall.reject(
                "CAMERA_ERROR",
                e.message ?: "Failed to get camera information",
                e
            )
        } finally {
            finish()
        }
    }
}

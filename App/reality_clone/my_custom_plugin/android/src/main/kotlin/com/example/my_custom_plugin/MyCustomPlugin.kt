package com.example.my_custom_plugin

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MyCustomPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  private var channel: MethodChannel? = null
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "my_custom_plugin")
    channel?.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getFocalLengths") {
      val focalLengths = getFocalLengthsInPixels()
      result.success(focalLengths) // Retourne un Map<String, Float>
    } else {
      result.notImplemented()
    }
  }


  private fun getFocalLengthsInPixels(): Map<String, Float> {
    try {
      val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
      val cameraId = cameraManager.cameraIdList[0]
      val characteristics = cameraManager.getCameraCharacteristics(cameraId)

      val focalLengths = characteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
      val focalLengthInMm = focalLengths?.getOrNull(0) ?: return mapOf("fx" to 0.0f, "fy" to 0.0f)

      val sensorSize = characteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)
      val sensorWidth = sensorSize?.width ?: return mapOf("fx" to 0.0f, "fy" to 0.0f)
      val sensorHeight = sensorSize?.height ?: return mapOf("fx" to 0.0f, "fy" to 0.0f)

      val streamConfigurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
      val outputSizes = streamConfigurationMap?.getOutputSizes(android.graphics.ImageFormat.JPEG)
      val resolutionWidth = outputSizes?.getOrNull(0)?.width ?: return mapOf("fx" to 0.0f, "fy" to 0.0f)
      val resolutionHeight = outputSizes?.getOrNull(0)?.height ?: return mapOf("fx" to 0.0f, "fy" to 0.0f)

      val fx = (focalLengthInMm * resolutionWidth) / sensorWidth
      val fy = (focalLengthInMm * resolutionHeight) / sensorHeight

      return mapOf("fx" to fx, "fy" to fy)
    } catch (e: Exception) {
      e.printStackTrace()
    }
    return mapOf("fx" to 0.0f, "fy" to 0.0f)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
  }
}

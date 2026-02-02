package com.abdalsalam.logic.flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Process
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AbdalsalamLogicFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "runtime_control/android")
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    android.util.Log.d("AbdalsalamPlugin", "Method called: ${call.method}")
    
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "restartApp" -> {
        try {
          val success = restartApplication()
          android.util.Log.d("AbdalsalamPlugin", "Restart result: $success")
          result.success(success)
        } catch (e: Exception) {
          android.util.Log.e("AbdalsalamPlugin", "Restart failed", e)
          result.error("RESTART_FAILED", e.message, null)
        }
      }
      "forceKillAndRestart" -> {
        try {
          forceKillAndRestart()
          android.util.Log.d("AbdalsalamPlugin", "Force restart initiated")
          result.success(true)
        } catch (e: Exception) {
          android.util.Log.e("AbdalsalamPlugin", "Force restart failed", e)
          result.error("FORCE_RESTART_FAILED", e.message, null)
        }
      }
      else -> {
        android.util.Log.w("AbdalsalamPlugin", "Unknown method: ${call.method}")
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }

  private fun restartApplication(): Boolean {
    android.util.Log.d("AbdalsalamPlugin", "Starting app restart")
    
    return try {
      val currentActivity = activity
      if (currentActivity != null) {
        val packageName = currentActivity.packageName
        val intent = currentActivity.packageManager.getLaunchIntentForPackage(packageName)
        
        if (intent != null) {
          intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
          intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          
          android.util.Log.d("AbdalsalamPlugin", "Starting new activity")
          currentActivity.startActivity(intent)
          
          // Finish current activity after a delay
          android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            currentActivity.finishAffinity()
          }, 100)
          
          true
        } else {
          android.util.Log.e("AbdalsalamPlugin", "Launch intent is null")
          false
        }
      } else {
        android.util.Log.e("AbdalsalamPlugin", "Activity is null")
        false
      }
    } catch (e: Exception) {
      android.util.Log.e("AbdalsalamPlugin", "Restart failed", e)
      false
    }
  }

  private fun forceKillAndRestart() {
    android.util.Log.d("AbdalsalamPlugin", "Starting force restart")
    
    try {
      val currentActivity = activity
      if (currentActivity != null) {
        val packageName = currentActivity.packageName
        val intent = currentActivity.packageManager.getLaunchIntentForPackage(packageName)
        
        if (intent != null) {
          intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
          intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          
          android.util.Log.d("AbdalsalamPlugin", "Starting new activity for force restart")
          currentActivity.startActivity(intent)
          
          // Kill process after starting new activity
          android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            android.util.Log.d("AbdalsalamPlugin", "Killing process")
            currentActivity.finishAffinity()
            Process.killProcess(Process.myPid())
          }, 50)
        } else {
          android.util.Log.w("AbdalsalamPlugin", "Launch intent null, just killing process")
          Process.killProcess(Process.myPid())
        }
      } else {
        android.util.Log.w("AbdalsalamPlugin", "Activity null, just killing process")
        Process.killProcess(Process.myPid())
      }
    } catch (e: Exception) {
      android.util.Log.e("AbdalsalamPlugin", "Force restart failed, killing process", e)
      Process.killProcess(Process.myPid())
    }
  }
}
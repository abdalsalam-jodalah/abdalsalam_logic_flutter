package com.abdalsalam.logic.flutter

import android.content.Intent
import android.os.Process
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AbdalsalamLogicFlutterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "runtime_control/android")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "restartApp" -> {
        val success = restartApplication()
        result.success(success)
      }
      "forceKillAndRestart" -> {
        forceKillAndRestart()
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun restartApplication(): Boolean {
    return try {
      val context = channel.binaryMessenger as? io.flutter.embedding.engine.FlutterEngine
      val activity = context?.activity
      val packageManager = activity?.packageManager
      val intent = packageManager?.getLaunchIntentForPackage(activity.packageName)
      val componentName = intent?.component
      val mainIntent = Intent.makeRestartActivityTask(componentName)
      activity?.startActivity(mainIntent)
      Process.killProcess(Process.myPid())
      true
    } catch (e: Exception) {
      e.printStackTrace()
      false
    }
  }

  private fun forceKillAndRestart() {
    try {
      val context = channel.binaryMessenger as? io.flutter.embedding.engine.FlutterEngine
      val activity = context?.activity
      val packageManager = activity?.packageManager
      val intent = packageManager?.getLaunchIntentForPackage(activity.packageName)
      val componentName = intent?.component
      val mainIntent = Intent.makeRestartActivityTask(componentName)
      mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
      activity?.startActivity(mainIntent)
      
      // Force kill after starting new instance
      android.os.Handler().postDelayed({
        Process.killProcess(Process.myPid())
        System.exit(0)
      }, 100)
    } catch (e: Exception) {
      e.printStackTrace()
      Process.killProcess(Process.myPid())
    }
  }
}
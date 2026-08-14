package com.forebear.mathkingdombuilder

import android.content.pm.ActivityInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val isTablet: Boolean
        get() = resources.configuration.smallestScreenWidthDp >= 600

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        requestedOrientation = if (isTablet) {
            ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
        } else {
            ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.forebear.mathkingdombuilder/device",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTablet" -> result.success(isTablet)
                else -> result.notImplemented()
            }
        }
    }
}

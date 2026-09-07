package com.example.money_management_app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TAG = "NotificationService"
    private val CHANNEL = "com.example.money_management_app/app_intent"
    private var initialIntentAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val action = intent?.action
        initialIntentAction = action
        val categories = intent?.categories?.joinToString(",") ?: "none"
        val isBoot = action == Intent.ACTION_BOOT_COMPLETED ||
                action == "android.intent.action.QUICKBOOT_POWERON" ||
                action == "com.htc.intent.action.QUICKBOOT_POWERON" ||
                action == Intent.ACTION_MY_PACKAGE_REPLACED
        val isUserTap = action == Intent.ACTION_MAIN
        Log.i(
            TAG,
            "MainActivity.onCreate: action=$action, isUserTap=$isUserTap, isBoot=$isBoot, categories=$categories, data=${intent?.dataString}"
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val action = intent.action
        val categories = intent.categories?.joinToString(",") ?: "none"
        Log.i(
            TAG,
            "MainActivity.onNewIntent: action=$action, categories=$categories, data=${intent.dataString}"
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialIntentAction") {
                    result.success(initialIntentAction)
                } else {
                    result.notImplemented()
                }
            }
    }
}

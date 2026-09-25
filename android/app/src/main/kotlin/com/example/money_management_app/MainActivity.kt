package com.example.money_management_app

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
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
                when (call.method) {
                    "getInitialIntentAction" -> result.success(initialIntentAction)
                    "openAutostartSettings" -> result.success(openAutostartSettings())
                    "openBatterySaverSettings" -> result.success(openBatterySaverSettings())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Tries three Xiaomi-specific intents to reach the Autostart management screen,
     * falling back to the standard app-info screen on non-Xiaomi devices.
     * Returns true if a Xiaomi-specific screen was opened, false if the generic fallback was used.
     */
    private fun openAutostartSettings(): Boolean {
        // Attempt 1: Direct AutoStartManagementActivity
        try {
            val intent = Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.permcenter.autostart.AutoStartManagementActivity"
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openXiaomiAutostartSettings: launched AutoStartManagementActivity")
            return true
        } catch (e: Exception) {
            Log.w(TAG, "openAutostartSettings: attempt 1 failed: ${e.message}")
        }

        // Attempt 2: miui.intent.action.OP_AUTO_START with CATEGORY_DEFAULT
        try {
            val intent = Intent("miui.intent.action.OP_AUTO_START").apply {
                addCategory(Intent.CATEGORY_DEFAULT)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openXiaomiAutostartSettings: launched via miui.intent.action.OP_AUTO_START")
            return true
        } catch (e: Exception) {
            Log.w(TAG, "openAutostartSettings: attempt 2 failed: ${e.message}")
        }

        // Attempt 3: AppManagerAppInfoActivity
        try {
            val intent = Intent().apply {
                component = ComponentName(
                    "com.miui.securitycenter",
                    "com.miui.appmanager.AppManagerAppInfoActivity"
                )
                putExtra("package_name", packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openXiaomiAutostartSettings: launched AppManagerAppInfoActivity")
            return true
        } catch (e: Exception) {
            Log.w(TAG, "openAutostartSettings: attempt 3 failed: ${e.message}")
        }

        // Fallback: generic app details settings (non-Xiaomi path)
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openAutostartSettings: fallback to ACTION_APPLICATION_DETAILS_SETTINGS")
        } catch (e: Exception) {
            Log.e(TAG, "openAutostartSettings: all attempts failed: ${e.message}")
        }
        return false
    }

    /**
     * Tries the Xiaomi-specific POWER_HIDE_MODE_APP_LIST intent to reach the
     * per-app battery saver screen, falling back to the standard app-info screen.
     * Returns true if the Xiaomi-specific screen was opened, false if the generic fallback was used.
     */
    private fun openBatterySaverSettings(): Boolean {
        try {
            val intent = Intent("miui.intent.action.POWER_HIDE_MODE_APP_LIST").apply {
                putExtra("package_name", packageName)
                putExtra("package_label", "Vault")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openBatterySaverSettings: launched POWER_HIDE_MODE_APP_LIST")
            return true
        } catch (e: Exception) {
            Log.w(TAG, "openBatterySaverSettings: Xiaomi intent failed: ${e.message}")
        }

        // Fallback: generic app details settings (non-Xiaomi path)
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Log.i(TAG, "openBatterySaverSettings: fallback to ACTION_APPLICATION_DETAILS_SETTINGS")
        } catch (e: Exception) {
            Log.e(TAG, "openBatterySaverSettings: all attempts failed: ${e.message}")
        }
        return false
    }
}

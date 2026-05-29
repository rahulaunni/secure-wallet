package com.secure.swallet

import android.os.Build
import android.os.Bundle
import android.view.Display
import android.view.KeyEvent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val screenshotChannelName = "com.secure.swallet/screenshot_blocker"
    private var screenshotChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        screenshotChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            screenshotChannelName
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableScreenshotProtection()
        enableHighRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        enableScreenshotProtection()
        enableHighRefreshRate()
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_UP && event.keyCode == KeyEvent.KEYCODE_SYSRQ) {
            notifyScreenshotBlocked()
            return true
        }

        return super.dispatchKeyEvent(event)
    }

    private fun enableScreenshotProtection() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }

        val activityDisplay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        } ?: return

        val bestMode = activityDisplay.supportedModes
            .maxWithOrNull(
                compareBy<Display.Mode>({ it.refreshRate }).thenBy { it.physicalWidth * it.physicalHeight }
            ) ?: return

        val layoutParams = window.attributes
        var changed = false

        if (layoutParams.preferredDisplayModeId != bestMode.modeId) {
            layoutParams.preferredDisplayModeId = bestMode.modeId
            changed = true
        }

        @Suppress("DEPRECATION")
        if (layoutParams.preferredRefreshRate != bestMode.refreshRate) {
            layoutParams.preferredRefreshRate = bestMode.refreshRate
            changed = true
        }

        if (changed) {
            window.attributes = layoutParams
        }
    }

    private fun notifyScreenshotBlocked() {
        screenshotChannel?.invokeMethod("screenshotBlocked", null)
    }
}

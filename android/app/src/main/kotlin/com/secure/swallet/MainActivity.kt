package com.secure.swallet

import android.os.Bundle
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
    }

    override fun onResume() {
        super.onResume()
        enableScreenshotProtection()
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

    private fun notifyScreenshotBlocked() {
        screenshotChannel?.invokeMethod("screenshotBlocked", null)
    }
}

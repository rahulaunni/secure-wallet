package com.secure.swallet

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableScreenshotProtection()
    }

    override fun onResume() {
        super.onResume()
        enableScreenshotProtection()
    }

    private fun enableScreenshotProtection() {
        // Temporarily disabled so wallet design screenshots can be captured.
    }
}

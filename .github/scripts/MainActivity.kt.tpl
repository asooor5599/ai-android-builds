package com.aibuilder.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AibAgent.onStart(this)
    }

    override fun onResume() {
        super.onResume()
        AibAgent.onResume(this)
    }
}

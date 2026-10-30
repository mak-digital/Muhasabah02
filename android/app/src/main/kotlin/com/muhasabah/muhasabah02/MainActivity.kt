package com.muhasabah.muhasabah02

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val delivered = super.dispatchKeyEvent(event)
        // Host Delete is KEYCODE_FORWARD_DEL. If the activity does not consume
        // it, the Windows emulator can promote it to the Ctrl+Alt+Del screen.
        if (event.keyCode == KeyEvent.KEYCODE_FORWARD_DEL) {
            return true
        }
        return delivered
    }
}

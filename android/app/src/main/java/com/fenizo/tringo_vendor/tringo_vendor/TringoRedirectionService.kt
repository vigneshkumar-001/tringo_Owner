package com.fenizo.tringo_vendor.tringo_vendor

import android.net.Uri
import android.os.Build
import android.telecom.CallRedirectionService
import android.telecom.PhoneAccountHandle
import android.content.Intent
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

@RequiresApi(Build.VERSION_CODES.Q)
class TringoRedirectionService : CallRedirectionService() {

    override fun onPlaceCall(
        handle: Uri,
        phoneAccountHandle: PhoneAccountHandle,
        allowInteractiveResponse: Boolean
    ) {
        ContextCompat.startForegroundService(
            this,
            Intent(this, TringoOverlayService::class.java).apply {
                putExtra("cmd", "show")
                putExtra("name", "Tringo Outgoing")
                putExtra("number", "7871222346")
            }
        )
        // Always let the call continue
        placeCallUnmodified()
    }
}

package com.fenizo.tringo_owner.tringo_owner

import android.net.Uri
import android.telecom.CallRedirectionService
import android.telecom.PhoneAccountHandle
import android.util.Log

class TringoRedirectionService : CallRedirectionService() {

    private val TAG = "TRINGO_REDIRECT"

    override fun onPlaceCall(handle: Uri, initialPhoneAccount: PhoneAccountHandle, allowInteractiveResponse: Boolean) {
        try {
            val number = handle.schemeSpecificPart?.trim().orEmpty()
            Log.d(TAG, "onPlaceCall number=$number allowInteractive=$allowInteractiveResponse")

            if (number.isNotBlank()) {
                // Optional: prime overlay after call end (outgoing). InCallService is still most reliable.
                TringoOverlayService.start(
                    ctx = applicationContext,
                    phone = number,
                    contactName = "",
                    showOnCallEnd = true,
                    launchedByReceiver = false
                )
            }

            // ✅ Continue call normally (no redirection)
            placeCallUnmodified()

        } catch (e: Exception) {
            Log.e(TAG, "onPlaceCall error: ${e.message}", e)
            placeCallUnmodified()
        }
    }
}


//package com.fenizo.tringo_Owner.tringo_Owner
//
//import android.net.Uri
//import android.os.Build
//import android.telecom.CallRedirectionService
//import android.telecom.PhoneAccountHandle
//import android.content.Intent
//import androidx.annotation.RequiresApi
//import androidx.core.content.ContextCompat
//
//@RequiresApi(Build.VERSION_CODES.Q)
//class TringoRedirectionService : CallRedirectionService() {
//
//    override fun onPlaceCall(
//        handle: Uri,
//        phoneAccountHandle: PhoneAccountHandle,
//        allowInteractiveResponse: Boolean
//    ) {
//        ContextCompat.startForegroundService(
//            this,
//            Intent(this, TringoOverlayService::class.java).apply {
//                putExtra("cmd", "show")
//                putExtra("name", "Tringo Outgoing")
//                putExtra("number", "7871222346")
//            }
//        )
//        // Always let the call continue
//        placeCallUnmodified()
//    }
//}

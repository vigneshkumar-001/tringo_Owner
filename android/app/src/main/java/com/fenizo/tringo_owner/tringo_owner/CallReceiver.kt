package com.fenizo.tringo_owner.tringo_owner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class CallReceiver : BroadcastReceiver() {

    private val TAG = "TRINGO_CALL_RX"

    override fun onReceive(context: Context, intent: Intent) {
        try {
            val action = intent.action ?: ""
            if (action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
                action != "android.intent.action.PHONE_STATE" &&
                action != "android.intent.action.PHONE_STATE_CHANGED"
            ) return

            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE).orEmpty()
            val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER).orEmpty()

            Log.d(TAG, "onReceive state=$state number=$incomingNumber")

            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                val phone = incomingNumber.ifBlank { "UNKNOWN" }

                // ✅ start overlay on incoming
                TringoOverlayService.start(
                    ctx = context.applicationContext,
                    phone = phone,
                    contactName = "",
                    showOnCallEnd = false,
                    launchedByReceiver = true
                )
            }
        } catch (t: Throwable) {
            Log.e(TAG, "Receiver crash: ${t.message}", t)
        }
    }
}


//package com.fenizo.tringo_Owner.tringo_Owner
//
//import android.content.BroadcastReceiver
//import android.content.Context
//import android.content.Intent
//import android.telephony.TelephonyManager
//import androidx.core.content.ContextCompat
//
//class CallReceiver : BroadcastReceiver() {
//    override fun onReceive(context: Context, intent: Intent) {
//        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
//        android.util.Log.d("TringoReceiver", "PHONE_STATE = $state")
//        when (state) {
//            TelephonyManager.EXTRA_STATE_RINGING -> {
//                androidx.core.content.ContextCompat.startForegroundService(
//                    context,
//                    Intent(context, TringoOverlayService::class.java).apply {
//                        putExtra("cmd", "show")
//                        putExtra("name", "Tringo Incoming")
//                        putExtra("number", "7871222346")
//                    }
//                )
//            }
//            TelephonyManager.EXTRA_STATE_IDLE,
//            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
//                androidx.core.content.ContextCompat.startForegroundService(
//                    context,
//                    Intent(context, TringoOverlayService::class.java).apply { putExtra("cmd", "hide") }
//                )
//            }
//        }
//    }
//
//}

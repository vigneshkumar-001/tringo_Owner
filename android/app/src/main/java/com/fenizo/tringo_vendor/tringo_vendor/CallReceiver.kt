package com.fenizo.tringo_Owner.tringo_Owner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat

class CallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        android.util.Log.d("TringoReceiver", "PHONE_STATE = $state")
        when (state) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                androidx.core.content.ContextCompat.startForegroundService(
                    context,
                    Intent(context, TringoOverlayService::class.java).apply {
                        putExtra("cmd", "show")
                        putExtra("name", "Tringo Incoming")
                        putExtra("number", "7871222346")
                    }
                )
            }
            TelephonyManager.EXTRA_STATE_IDLE,
            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                androidx.core.content.ContextCompat.startForegroundService(
                    context,
                    Intent(context, TringoOverlayService::class.java).apply { putExtra("cmd", "hide") }
                )
            }
        }
    }

}

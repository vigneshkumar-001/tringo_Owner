package com.fenizo.tringo_Owner.tringo_Owner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.Point
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.core.app.NotificationCompat

class TringoOverlayService : Service() {

    private lateinit var wm: WindowManager
    private var overlayView: View? = null
    private val channelId = "tringo_overlay"

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(1, buildNotif("Active"))
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.getStringExtra("cmd")) {
            "show", "showManual" -> {
                val number = intent.getStringExtra("number")
                val name = intent.getStringExtra("name") ?: resolveName(number)
                showCard(name, number)
            }
            "showOnce" -> {
                val name = intent.getStringExtra("name") ?: "Tringo User"
                val number = intent.getStringExtra("number") ?: "--"
                showCard(name, number)
                Handler(mainLooper).postDelayed({
                    hideCard()
                    stopSelf()
                }, 4000L)
            }
            "hide" -> {
                hideCard()
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(
                NotificationChannel(channelId, "Tringo Caller Card", NotificationManager.IMPORTANCE_LOW)
            )
        }
    }

    private fun buildNotif(text: String): Notification =
        NotificationCompat.Builder(this, channelId)
            .setContentTitle("Tringo Caller Card")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.sym_call_incoming)
            .build()

    // dp -> px helper
    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    private fun showCard(name: String?, number: String?) {
        if (overlayView != null) return

        val type = if (Build.VERSION.SDK_INT >= 26)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,                // FULL WIDTH
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL      // center horizontally
            x = 0
            y = 0                                                   // we’ll center vertically after measure
        }

        val overlay = LayoutInflater.from(this).inflate(R.layout.popup_tringo, null)

        overlay.findViewById<TextView>(R.id.tvName)?.text = name ?: "Unknown"
        overlay.findViewById<TextView>(R.id.numberText)?.text = number ?: "--"
        overlay.findViewById<View>(R.id.btnClose)?.setOnClickListener {
            hideCard(); stopSelf()
        }

        // Vertical drag (up/down). Horizontal drag isn’t meaningful for full width.
        overlay.setOnTouchListener(object : View.OnTouchListener {
            var startY = 0
            var touchY = 0f
            override fun onTouch(v: View, e: MotionEvent): Boolean {
                when (e.action) {
                    MotionEvent.ACTION_DOWN -> {
                        startY = params.y
                        touchY = e.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.y = (startY + (e.rawY - touchY)).toInt()
                        wm.updateViewLayout(overlay, params)
                        return true
                    }
                }
                return false
            }
        })

        wm.addView(overlay, params)
        overlayView = overlay

        // Center vertically once it’s measured
        overlay.post {
            val size = android.graphics.Point()
            wm.defaultDisplay.getSize(size)
            val h = overlay.height
            params.y = (size.y - h) / 2
            wm.updateViewLayout(overlay, params)
        }
    }


    private fun hideCard() {
        overlayView?.let { wm.removeView(it) }
        overlayView = null
    }

    // TODO: plug your API/DB here if you want real names
    private fun resolveName(number: String?): String = "Tringo User"

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        hideCard()
        super.onDestroy()
    }
}

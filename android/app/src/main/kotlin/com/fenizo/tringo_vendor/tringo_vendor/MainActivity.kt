package com.fenizo.tringo_Owner.tringo_Owner

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.app.role.RoleManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "tringo/overlay"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "requestOverlayPermission" -> {
            val ok = Settings.canDrawOverlays(this)
            if (!ok) {
              val i = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:")
              )
              startActivity(i)
              result.success(false)
            } else {
              result.success(true)
            }
          }

          "startOverlayService" -> {
            ContextCompat.startForegroundService(
              this,
              Intent(this, TringoOverlayService::class.java).apply {
                putExtra("cmd", "showManual")
                putExtra("number", "Manual Test")
              }
            )
            result.success(null)
          }

          "stopOverlayService" -> {
            stopService(Intent(this, TringoOverlayService::class.java))
            result.success(null)
          }

          "requestCallRedirectionRole" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
              try {
                val rm = getSystemService(RoleManager::class.java)
                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_REDIRECTION)
                // Simple start; user returns themselves. No result handling needed.
                startActivity(intent)
              } catch (_: Exception) {
                // ignore
              }
            }
            result.success(null)
          }

          else -> result.notImplemented()
        }
      }
  }
}

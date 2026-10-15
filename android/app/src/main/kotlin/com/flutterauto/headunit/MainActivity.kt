package com.flutterauto.headunit

import android.content.ActivityNotFoundException
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val appExecutor = Executors.newSingleThreadExecutor()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter_auto/device")
            .setMethodCallHandler { call, result ->
                try {
                    val audio = getSystemService(AUDIO_SERVICE) as AudioManager
                    when (call.method) {
                        "openMaps" -> {
                            // Open Maps normally; do not imply a destination or GPS fix.
                            val maps = packageManager.getLaunchIntentForPackage("com.google.android.apps.maps")
                            if (maps != null) {
                                startActivity(maps)
                            } else {
                                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com/maps")))
                            }
                            result.success(null)
                        }
                        "openPhone" -> {
                            // Open the dialer; never initiate a call or request contact access.
                            startActivity(Intent(Intent.ACTION_DIAL))
                            result.success(null)
                        }
                        "openSettings" -> {
                            startActivity(Intent(Settings.ACTION_SETTINGS))
                            result.success(null)
                        }
                        "openAndroidAuto", "openAndroidAutoProjection", "openAndroidAutoScreen",
                        "startAndroidAuto", "launchAndroidAuto", "connectAndroidAuto",
                        "showAndroidAuto" -> {
                            // Open Android Auto projection when available. This device acts as the
                            // headunit display for a phone connected over USB.
                            val intent = packageManager.getLaunchIntentForPackage(
                                "com.google.android.projection.gearhead",
                            )
                            if (intent != null) {
                                startActivity(intent)
                            } else {
                                throw ActivityNotFoundException()
                            }
                            result.success(null)
                        }
                        "getVolume" -> {
                            if (audio.isVolumeFixed) {
                                result.error("fixed_volume", "This device has fixed media volume.", null)
                            } else {
                                val max = audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                                val value = audio.getStreamVolume(AudioManager.STREAM_MUSIC)
                                result.success(if (max == 0) 0.0 else value.toDouble() / max)
                            }
                        }
                        "setVolume" -> {
                            val value = call.argument<Number>("value")?.toDouble()
                            if (value == null || !value.isFinite()) {
                                result.error("invalid_volume", "A finite volume is required.", null)
                            } else if (audio.isVolumeFixed) {
                                result.error("fixed_volume", "This device has fixed media volume.", null)
                            } else {
                                val max = audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                                audio.setStreamVolume(AudioManager.STREAM_MUSIC,
                                    (value.coerceIn(0.0, 1.0) * max).roundToInt(), 0)
                                result.success(null)
                            }
                        }
                        "getApps" -> appExecutor.execute {
                            try {
                                val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                                @Suppress("DEPRECATION")
                                val apps = packageManager.queryIntentActivities(launcher, 0)
                                    .filter { it.activityInfo.packageName != packageName }
                                    .distinctBy { it.activityInfo.packageName }
                                    .map { mapOf("name" to it.loadLabel(packageManager).toString(),
                                        "packageName" to it.activityInfo.packageName) }
                                    .sortedBy { it["name"]?.lowercase() }
                                runOnUiThread { result.success(apps) }
                            } catch (_: Exception) {
                                runOnUiThread { result.error("apps_unavailable", "Unable to load installed apps.", null) }
                            }
                        }
                        "launchApp" -> {
                            val target = call.argument<String>("packageName")
                            val intent = target?.let { packageManager.getLaunchIntentForPackage(it) }
                            if (intent == null) {
                                result.error("app_unavailable", "This app is no longer available.", null)
                            } else {
                                startActivity(intent)
                                result.success(null)
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (_: ActivityNotFoundException) {
                    result.error("app_unavailable", "No app is installed to handle this action.", null)
                } catch (_: SecurityException) {
                    result.error("permission_denied", "Android did not allow this action.", null)
                } catch (_: Exception) {
                    result.error("device_error", "The device could not complete this action.", null)
                }
            }
    }

    override fun onDestroy() {
        appExecutor.shutdown()
        super.onDestroy()
    }
}

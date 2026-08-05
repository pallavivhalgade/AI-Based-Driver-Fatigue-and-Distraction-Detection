package com.example.driver_monitor_app

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "auto_sms_channel"
    private val SMS_PERMISSION_REQUEST_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendSms") {
                val phone = call.argument<String>("phone")
                val message = call.argument<String>("message")

                if (phone.isNullOrBlank() || message.isNullOrBlank()) {
                    result.success(false)
                    return@setMethodCallHandler
                }

                if (ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.SEND_SMS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.SEND_SMS),
                        SMS_PERMISSION_REQUEST_CODE
                    )
                    result.success(false)
                    return@setMethodCallHandler
                }

                try {
                    val smsManager: SmsManager = SmsManager.getDefault()

                    val parts = smsManager.divideMessage(message)

                    smsManager.sendMultipartTextMessage(
                        phone,
                        null,
                        parts,
                        null,
                        null
                    )

                    result.success(true)

                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}
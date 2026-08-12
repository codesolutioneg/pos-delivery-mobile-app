package org.codesolution.dishflow_delivery

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

/**
 * Exposes this app's package name + signing certificate SHA-1 to Dart.
 *
 * Google API keys restricted to Android apps accept web-service calls only when
 * the request carries the `X-Android-Package` / `X-Android-Cert` headers, which
 * the Maps SDK adds for itself but a plain HTTP client does not. The Routes API
 * call in `OrderRouteResolver` needs them.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "org.codesolution.dishflow_delivery/app_identity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSigningIdentity" -> result.success(
                        mapOf(
                            "packageName" to packageName,
                            "sha1" to signingCertificateSha1(),
                        )
                    )
                    else -> result.notImplemented()
                }
            }
    }

    /** Uppercase hex SHA-1 of the signing certificate, or null if unavailable. */
    private fun signingCertificateSha1(): String? {
        return try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES,
                )
                @Suppress("DEPRECATION")
                info.signatures
            }

            val first = signatures?.firstOrNull() ?: return null
            val digest = MessageDigest.getInstance("SHA-1").digest(first.toByteArray())
            digest.joinToString("") { "%02X".format(it) }
        } catch (e: Exception) {
            null
        }
    }
}

package de.wger.flutter

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Started only to show the policy, so there is nothing to come back to
        if (isPrivacyPolicyRequest(intent) && openPrivacyPolicy()) {
            finish()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // The app was already running, it stays open behind the browser
        if (isPrivacyPolicyRequest(intent)) {
            openPrivacyPolicy()
        }
    }

    private fun isPrivacyPolicyRequest(intent: Intent?): Boolean {
        val action = intent?.action ?: return false
        return action in PRIVACY_POLICY_ACTIONS
    }

    /** Returns false when no browser took the intent, so the app stays open. */
    private fun openPrivacyPolicy(): Boolean {
        return try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_POLICY_URL)))
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    companion object {
        // Health Connect starts the app with these when the user asks for its
        // privacy policy: from the permission dialog, and from the system
        // settings on Android 14 and later. Both are declared in the manifest.
        private val PRIVACY_POLICY_ACTIONS = setOf(
            "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE",
            "android.intent.action.VIEW_PERMISSION_USAGE",
        )

        // The page of PRIVACY_POLICY_URL in lib/core/consts.dart, at the
        // section describing the health import
        private const val PRIVACY_POLICY_URL =
            "https://wger.de/software/terms-of-service#health-data"
    }
}

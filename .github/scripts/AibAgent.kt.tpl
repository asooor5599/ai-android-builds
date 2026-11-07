package com.aibuilder.app

import android.app.Activity
import android.app.AlertDialog
import android.app.DownloadManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

/**
 * Added automatically by AI Android App Builder.
 * - Anonymous usage stats (random install id, app version, Android version, device model) once per day.
 * - In-app update notice when a newer version of this app is published.
 */
object AibAgent {
    private const val ENDPOINT = "__ENDPOINT__"
    private const val APP_ID = "__APP_ID__"
    private const val TELEMETRY = __TELEMETRY__
    private const val UPDATES = __UPDATES__
    private const val PREFS = "aib_agent"

    @Volatile private var pendingUpdate: JSONObject? = null
    @Volatile private var dialogShown = false

    fun onStart(activity: Activity) {
        if (!TELEMETRY && !UPDATES) return
        val ctx = activity.applicationContext
        Thread {
            try {
                val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
                val lastDay = p.getString("lastDay", null)
                val now = System.currentTimeMillis()
                val lastCheck = p.getLong("lastCheck", 0L)
                val sendStats = TELEMETRY && lastDay != today
                val checkUpdate = UPDATES && (now - lastCheck > 3 * 3600 * 1000L || sendStats)
                if (!sendStats && !checkUpdate) return@Thread

                val body = JSONObject()
                body.put("app", APP_ID)
                body.put("vc", versionCode(ctx))
                body.put("vn", versionName(ctx))
                body.put("ev", if (!sendStats) "check" else if (lastDay == null) "install" else "open")
                if (TELEMETRY) {
                    var uid = p.getString("uid", null)
                    if (uid == null) { uid = UUID.randomUUID().toString(); p.edit().putString("uid", uid).apply() }
                    body.put("uid", uid)
                    body.put("sdk", Build.VERSION.SDK_INT)
                    body.put("model", (Build.MANUFACTURER + " " + Build.MODEL).take(60))
                }
                val res = post(body.toString()) ?: return@Thread
                val ed = p.edit().putLong("lastCheck", now)
                if (sendStats) ed.putString("lastDay", today)
                ed.apply()
                if (UPDATES) {
                    val upd = JSONObject(res).optJSONObject("update")
                    if (upd != null && upd.optLong("vc", 0) > versionCode(ctx) && upd.optString("url").startsWith("http")) {
                        pendingUpdate = upd
                        Handler(Looper.getMainLooper()).post { showDialog(activity) }
                    }
                }
            } catch (e: Throwable) { }
        }.start()
    }

    fun onResume(activity: Activity) {
        val u = pendingUpdate ?: return
        if (u.optBoolean("force", false)) { dialogShown = false; showDialog(activity) }
    }

    private fun showDialog(activity: Activity) {
        val u = pendingUpdate ?: return
        if (dialogShown || activity.isFinishing || (Build.VERSION.SDK_INT >= 17 && activity.isDestroyed)) return
        dialogShown = true
        val force = u.optBoolean("force", false)
        val vn = u.optString("vn", "")
        val notes = u.optString("notes", "")
        val msg = StringBuilder()
        msg.append(if (force) "يلزم تحديث التطبيق للاستمرار في استخدامه." else "يتوفر إصدار جديد من التطبيق.")
        if (vn.isNotEmpty()) msg.append("\nالإصدار: ").append(vn)
        if (notes.isNotEmpty()) msg.append("\n\n").append(notes.take(400))
        val b = AlertDialog.Builder(activity)
            .setTitle("تحديث جديد متوفر")
            .setMessage(msg.toString())
            .setCancelable(!force)
            .setPositiveButton("تحديث") { _, _ ->
                dialogShown = false
                download(activity, u)
            }
        if (!force) b.setNegativeButton("لاحقاً") { _, _ -> pendingUpdate = null }
        b.setOnDismissListener { if (!force) dialogShown = false }
        try { b.show() } catch (e: Throwable) { dialogShown = false }
    }

    private fun download(activity: Activity, u: JSONObject) {
        val url = u.optString("url")
        try {
            val dm = activity.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            val label = try { activity.applicationInfo.loadLabel(activity.packageManager).toString() } catch (e: Throwable) { "التطبيق" }
            val req = DownloadManager.Request(Uri.parse(url))
                .addRequestHeader("ngrok-skip-browser-warning", "1")
                .setTitle("تحديث " + label)
                .setDescription("الإصدار " + u.optString("vn", ""))
                .setMimeType("application/vnd.android.package-archive")
                .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, "update-" + activity.packageName + "-" + u.optLong("vc", 0) + ".apk")
            dm.enqueue(req)
            Toast.makeText(activity, "جاري تنزيل التحديث… اضغط على الإشعار بعد انتهاء التنزيل لتثبيته", Toast.LENGTH_LONG).show()
        } catch (e: Throwable) {
            try { activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) } catch (e2: Throwable) { }
        }
    }

    private fun post(json: String): String? {
        var c: HttpURLConnection? = null
        return try {
            c = URL(ENDPOINT).openConnection() as HttpURLConnection
            c.requestMethod = "POST"
            c.connectTimeout = 8000
            c.readTimeout = 8000
            c.doOutput = true
            c.setRequestProperty("Content-Type", "application/json; charset=utf-8")
            c.setRequestProperty("ngrok-skip-browser-warning", "1")
            c.outputStream.use { it.write(json.toByteArray(Charsets.UTF_8)) }
            if (c.responseCode in 200..299) c.inputStream.bufferedReader().use { it.readText() } else null
        } catch (e: Throwable) { null } finally { c?.disconnect() }
    }

    private fun versionCode(ctx: Context): Long = try {
        val pi = ctx.packageManager.getPackageInfo(ctx.packageName, 0)
        if (Build.VERSION.SDK_INT >= 28) pi.longVersionCode else @Suppress("DEPRECATION") pi.versionCode.toLong()
    } catch (e: Throwable) { 0L }

    private fun versionName(ctx: Context): String = try {
        ctx.packageManager.getPackageInfo(ctx.packageName, 0).versionName ?: ""
    } catch (e: Throwable) { "" }
}

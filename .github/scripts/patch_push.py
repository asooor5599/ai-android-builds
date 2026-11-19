"""Add Firebase Cloud Messaging (server push notifications) natively — no Dart changes needed.

usage: python3 patch_push.py <app.json>    (Flutter project root, after google-services.json was written)
- Gradle: google-services plugin + firebase-messaging (BOM)
- Kotlin: AibPush (channel, Android 13 permission, topic subscription: "<appId>" and "all")
          AibMessagingService (shows notifications while the app is open too)
- Manifest: service + default channel/icon
"""
import glob
import json
import os
import re
import sys

app = json.load(open(sys.argv[1], encoding='utf-8'))
app_id = app.get('appId') or 'com.aibuilder.app'
topic = re.sub(r'[^A-Za-z0-9_.~%-]', '_', app_id)

# --- gradle
sp = 'android/settings.gradle.kts'
s = open(sp, encoding='utf-8').read()
if 'com.google.gms.google-services' not in s:
    s, n = re.subn(r'(plugins\s*\{[^}]*?id\("com\.android\.application"\)[^\n]*\n)',
                   r'\1    id("com.google.gms.google-services") version "4.4.2" apply false\n', s, count=1)
    if not n:
        s = s.replace('plugins {', 'plugins {\n    id("com.google.gms.google-services") version "4.4.2" apply false', 1)
    open(sp, 'w', encoding='utf-8').write(s)
gp = 'android/app/build.gradle.kts'
g = open(gp, encoding='utf-8').read()
if 'com.google.gms.google-services' not in g:
    g, n = re.subn(r'(\n\s*id\("com\.android\.application"\)[^\n]*)', r'\1\n    id("com.google.gms.google-services")', g, count=1)
    if not n:
        g = re.sub(r'plugins\s*\{', 'plugins {\n    id("com.google.gms.google-services")', g, count=1)
if 'firebase-messaging' not in g:
    g += '\ndependencies {\n    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))\n    implementation("com.google.firebase:firebase-messaging")\n    implementation("androidx.core:core-ktx:1.13.1")\n}\n'
open(gp, 'w', encoding='utf-8').write(g)

# --- kotlin
ma = glob.glob('android/app/src/main/**/MainActivity.kt', recursive=True)[0]
src = open(ma, encoding='utf-8').read()
pkg = re.search(r'^package\s+([\w.]+)', src, flags=re.M).group(1)
d = os.path.dirname(ma)
open(os.path.join(d, 'AibPush.kt'), 'w', encoding='utf-8').write('''package %(pkg)s

import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import com.google.firebase.messaging.FirebaseMessaging

/** Added by AI App Builder: server push notifications (Firebase Cloud Messaging). */
object AibPush {
    const val CHANNEL = "aib_default"

    fun channel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL) == null) {
                nm.createNotificationChannel(NotificationChannel(CHANNEL, "الإشعارات", NotificationManager.IMPORTANCE_HIGH))
            }
        }
    }

    fun init(activity: Activity) {
        try {
            channel(activity)
            if (Build.VERSION.SDK_INT >= 33 &&
                activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                val p = activity.getSharedPreferences("aib_push", Context.MODE_PRIVATE)
                if (!p.getBoolean("asked", false)) {
                    p.edit().putBoolean("asked", true).apply()
                    activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 7701)
                }
            }
            val fm = FirebaseMessaging.getInstance()
            fm.subscribeToTopic("%(topic)s")
            fm.subscribeToTopic("all")
        } catch (e: Throwable) { }
    }
}
''' % {'pkg': pkg, 'topic': topic})
open(os.path.join(d, 'AibMessagingService.kt'), 'w', encoding='utf-8').write('''package %(pkg)s

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/** Shows push notifications also while the app is in the foreground. */
class AibMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        try {
            val n = message.notification
            val title = n?.title ?: message.data["title"] ?: return
            val body = n?.body ?: message.data["body"] ?: ""
            AibPush.channel(this)
            val intent = Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val flags = if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT else PendingIntent.FLAG_UPDATE_CURRENT
            val pi = PendingIntent.getActivity(this, 0, intent, flags)
            val b = NotificationCompat.Builder(this, AibPush.CHANNEL)
                .setSmallIcon(applicationInfo.icon)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setContentIntent(pi)
            NotificationManagerCompat.from(this).notify((System.currentTimeMillis() %% 100000).toInt(), b.build())
        } catch (e: Throwable) { }
    }

    override fun onNewToken(token: String) { }
}
''' % {'pkg': pkg})

# MainActivity: call AibPush.init(this) in onCreate
if 'AibPush.init' not in src:
    if 'override fun onCreate' in src:
        src = re.sub(r'(super\.onCreate\([^)]*\)\s*\n)', r'\1        AibPush.init(this)\n', src, count=1)
    else:
        src = re.sub(r'(class\s+MainActivity\s*:\s*[\w.]+\(\)\s*)(\{\s*\}|$)',
                     r'\1{\n    override fun onCreate(savedInstanceState: android.os.Bundle?) {\n        super.onCreate(savedInstanceState)\n        AibPush.init(this)\n    }\n}\n',
                     src, count=1, flags=re.M)
    open(ma, 'w', encoding='utf-8').write(src)

# --- manifest
mp = 'android/app/src/main/AndroidManifest.xml'
m = open(mp, encoding='utf-8').read()
if 'android.permission.POST_NOTIFICATIONS' not in m:
    m = m.replace('<application', '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>\n    <application', 1)
if 'AibMessagingService' not in m:
    m = m.replace('</application>', '''        <service android:name=".AibMessagingService" android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" android:value="aib_default" />
    </application>''', 1)
open(mp, 'w', encoding='utf-8').write(m)
print('push ready: topic', topic, '| MainActivity patched:', 'AibPush.init' in src)

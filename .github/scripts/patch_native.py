"""Automatic native Android setup for plugins that need it (run from the Flutter project root).

- flutter_local_notifications : scheduled/background local notifications
    -> notification permissions, boot/scheduled receivers, core library desugaring
- audio_service / just_audio_background : media controls in the notification shade + lock screen
    -> foreground media service, media button receiver, MainActivity extends AudioServiceActivity

Safe to run on any project: does nothing when those plugins are not used.
"""
import glob
import re
import sys

PUB = open('pubspec.yaml', encoding='utf-8').read()
deps = set(re.findall(r'^\s{2}([a-z0-9_]+):', PUB, flags=re.M))
notif = 'flutter_local_notifications' in deps
audio = bool(deps & {'audio_service', 'just_audio_background'})
if not (notif or audio):
    print('native patch: nothing to do')
    sys.exit(0)

MP = 'android/app/src/main/AndroidManifest.xml'
m = open(MP, encoding='utf-8').read()


def add_perm(name):
    global m
    if 'android:name="%s"' % name in m:
        return
    m = m.replace('<application', '<uses-permission android:name="%s"/>\n    <application' % name, 1)


def add_in_app(marker, xml):
    global m
    if marker in m:
        return
    m = m.replace('</application>', xml + '\n    </application>', 1)


if notif:
    for p in ('android.permission.POST_NOTIFICATIONS', 'android.permission.RECEIVE_BOOT_COMPLETED',
              'android.permission.VIBRATE', 'android.permission.SCHEDULE_EXACT_ALARM'):
        add_perm(p)
    add_in_app('ScheduledNotificationReceiver', '''        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />''')

    # core library desugaring (required by flutter_local_notifications)
    gp = 'android/app/build.gradle.kts'
    g = open(gp, encoding='utf-8').read()
    if 'isCoreLibraryDesugaringEnabled' not in g:
        g, n = re.subn(r'compileOptions\s*\{', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', g, count=1)
        if not n:
            g = g.replace('android {', 'android {\n    compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n    }', 1)
    if 'desugar_jdk_libs' not in g:
        g += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    open(gp, 'w', encoding='utf-8').write(g)

if audio:
    for p in ('android.permission.WAKE_LOCK', 'android.permission.FOREGROUND_SERVICE',
              'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK', 'android.permission.POST_NOTIFICATIONS',
              'android.permission.INTERNET'):
        add_perm(p)
    add_in_app('com.ryanheise.audioservice.AudioService', '''        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback" android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>''')
    for ma in glob.glob('android/app/src/main/**/MainActivity.kt', recursive=True):
        s = open(ma, encoding='utf-8').read()
        s2 = re.sub(r':\s*FlutterActivity\(\)', ': com.ryanheise.audioservice.AudioServiceActivity()', s)
        open(ma, 'w', encoding='utf-8').write(s2)
        print('MainActivity -> AudioServiceActivity:', ma, s2 != s)

open(MP, 'w', encoding='utf-8').write(m)
print('native patch: notifications=%s media=%s' % (notif, audio))

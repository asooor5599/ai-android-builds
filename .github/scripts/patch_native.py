"""Automatic native Android setup for plugins that need it (run from the Flutter project root).

- flutter_local_notifications : scheduled/background local notifications
    -> notification permissions, boot/scheduled receivers, core library desugaring
- audio_service / just_audio_background : media controls in the notification shade + lock screen
    -> foreground media service, media button receiver, MainActivity extends AudioServiceActivity

- more recipes (camera/QR, location, biometrics, url_launcher queries, speech, bluetooth, NFC, step counter …) below

Safe to run on any project: does nothing when those plugins are not used.
"""
import glob
import re
import sys

PUB = open('pubspec.yaml', encoding='utf-8').read()
deps = set(re.findall(r'^\s{2}([a-z0-9_]+):', PUB, flags=re.M))
notif = 'flutter_local_notifications' in deps
audio = bool(deps & {'audio_service', 'just_audio_background'})

# package -> permissions (simple recipes)
PERMS = {
    'image_picker': ['android.permission.CAMERA'],
    'camera': ['android.permission.CAMERA', 'android.permission.RECORD_AUDIO'],
    'mobile_scanner': ['android.permission.CAMERA'],
    'qr_code_scanner_plus': ['android.permission.CAMERA'],
    'geolocator': ['android.permission.ACCESS_FINE_LOCATION', 'android.permission.ACCESS_COARSE_LOCATION'],
    'location': ['android.permission.ACCESS_FINE_LOCATION', 'android.permission.ACCESS_COARSE_LOCATION'],
    'local_auth': ['android.permission.USE_BIOMETRIC'],
    'speech_to_text': ['android.permission.RECORD_AUDIO', 'android.permission.BLUETOOTH', 'android.permission.BLUETOOTH_ADMIN', 'android.permission.BLUETOOTH_CONNECT'],
    'record': ['android.permission.RECORD_AUDIO'],
    'pedometer': ['android.permission.ACTIVITY_RECOGNITION'],
    'nfc_manager': ['android.permission.NFC'],
    'flutter_blue_plus': ['android.permission.BLUETOOTH_SCAN', 'android.permission.BLUETOOTH_CONNECT', 'android.permission.ACCESS_FINE_LOCATION'],
    'print_bluetooth_thermal': ['android.permission.BLUETOOTH_SCAN', 'android.permission.BLUETOOTH_CONNECT', 'android.permission.ACCESS_FINE_LOCATION'],
    'blue_thermal_printer': ['android.permission.BLUETOOTH_SCAN', 'android.permission.BLUETOOTH_CONNECT', 'android.permission.ACCESS_FINE_LOCATION'],
    'wakelock_plus': ['android.permission.WAKE_LOCK'],
    'workmanager': ['android.permission.RECEIVE_BOOT_COMPLETED'],
    'vibration': ['android.permission.VIBRATE'],
    'webview_flutter': ['android.permission.INTERNET'],
    'video_player': ['android.permission.INTERNET'],
}
# Android 11+ package visibility: without these, url_launcher / TTS / speech silently do nothing
QUERIES = {
    'url_launcher': [('android.intent.action.VIEW', 'https'), ('android.intent.action.VIEW', 'http'),
                     ('android.intent.action.DIAL', 'tel'), ('android.intent.action.SENDTO', 'mailto'),
                     ('android.intent.action.SENDTO', 'smsto'), ('android.intent.action.VIEW', 'geo'),
                     ('android.intent.action.VIEW', 'whatsapp')],
    'flutter_tts': [('android.intent.action.TTS_SERVICE', None)],
    'speech_to_text': [('android.speech.RecognitionService', None)],
}
fragment = 'local_auth' in deps
extra = [d for d in deps if d in PERMS or d in QUERIES]
if not (notif or audio or extra):
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


for d in extra:
    for p in PERMS.get(d, []):
        add_perm(p)
if 'android.permission.CAMERA' in m:
    if 'android.hardware.camera' not in m:
        m = m.replace('<application', '<uses-feature android:name="android.hardware.camera" android:required="false"/>\n    <application', 1)
qs = [q for d in extra for q in QUERIES.get(d, [])]
if qs:
    items = ''
    for act, scheme in qs:
        if 'android:name="%s"' % act in m and (scheme is None or 'android:scheme="%s"' % scheme in m):
            continue
        items += '        <intent>\n            <action android:name="%s" />\n%s        </intent>\n' % (
            act, ('            <data android:scheme="%s" />\n' % scheme) if scheme else '')
    if 'url_launcher' in deps and 'com.whatsapp' not in m:
        items += '        <package android:name="com.whatsapp" />\n        <package android:name="com.whatsapp.w4b" />\n'
    if items:
        if '<queries>' in m:
            m = m.replace('<queries>', '<queries>\n' + items, 1)
        else:
            m = m.replace('</manifest>', '    <queries>\n' + items + '    </queries>\n</manifest>', 1)

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
        base = 'com.ryanheise.audioservice.AudioServiceFragmentActivity' if fragment else 'com.ryanheise.audioservice.AudioServiceActivity'
        s2 = re.sub(r':\s*FlutterActivity\(\)', ': %s()' % base, s)
        open(ma, 'w', encoding='utf-8').write(s2)
        print('MainActivity -> AudioServiceActivity:', ma, s2 != s)

if fragment and not audio:
    # local_auth (biometrics) needs a FragmentActivity
    for ma in glob.glob('android/app/src/main/**/MainActivity.kt', recursive=True):
        s = open(ma, encoding='utf-8').read()
        s2 = re.sub(r':\s*FlutterActivity\(\)', ': io.flutter.embedding.android.FlutterFragmentActivity()', s)
        open(ma, 'w', encoding='utf-8').write(s2)
        print('MainActivity -> FlutterFragmentActivity:', ma, s2 != s)

# newer plugin versions (and androidx.core) need compileSdk >= 37
gp = 'android/app/build.gradle.kts'
g = open(gp, encoding='utf-8').read()
if 'maxOf(flutter.compileSdkVersion' not in g:
    g, n = re.subn(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = maxOf(flutter.compileSdkVersion, 37)', g, count=1)
    print('compileSdk >= 37:', bool(n))
    open(gp, 'w', encoding='utf-8').write(g)
if extra and 'maxOf(flutter.minSdkVersion' not in g:
    # most hardware plugins need minSdk >= 24 (Android 7)
    g, n = re.subn(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = maxOf(flutter.minSdkVersion, 24)', g, count=1)
    print('minSdk >= 24:', bool(n))
    open(gp, 'w', encoding='utf-8').write(g)

open(MP, 'w', encoding='utf-8').write(m)
print('native patch: notifications=%s media=%s recipes=%s' % (notif, audio, sorted(extra)))

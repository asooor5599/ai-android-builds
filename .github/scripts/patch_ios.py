"""iOS setup for the generated Flutter app (run from the Flutter project root on macOS).

usage: python3 patch_ios.py <app.json>
- bundle id (iOS does not allow '_' -> '-'), display name, version
- Info.plist usage descriptions for the plugins in pubspec (camera, photos, location, Face ID, mic, speech,
  motion, Bluetooth, NFC), background audio, url_launcher schemes, Arabic localization
- iOS 15 minimum in the Podfile (needed by several plugins)
"""
import json
import plistlib
import re
import sys

app = json.load(open(sys.argv[1], encoding='utf-8'))
name = (app.get('appName') or 'App').strip()[:30]
ios_id = re.sub(r'[^A-Za-z0-9.-]', '-', app.get('appId') or 'com.aibuilder.app')
version = int(app.get('version') or 1)

pub = open('pubspec.yaml', encoding='utf-8').read()
deps = set(re.findall(r'^\s{2}([a-z0-9_]+):', pub, flags=re.M))

# bundle id in the Xcode project
pp = 'ios/Runner.xcodeproj/project.pbxproj'
s = open(pp, encoding='utf-8').read()
s = re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]*RunnerTests;', 'PRODUCT_BUNDLE_IDENTIFIER = %s.RunnerTests;' % ios_id, s)
s = re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = (?![^;]*RunnerTests)[^;]*;', 'PRODUCT_BUNDLE_IDENTIFIER = %s;' % ios_id, s)
s = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;', 'IPHONEOS_DEPLOYMENT_TARGET = 15.0;', s)
open(pp, 'w', encoding='utf-8').write(s)

# Podfile: iOS 15
try:
    pf = open('ios/Podfile', encoding='utf-8').read()
    pf = re.sub(r"^#?\s*platform :ios, '[0-9.]+'", "platform :ios, '15.0'", pf, count=1, flags=re.M)
    if "platform :ios" not in pf:
        pf = "platform :ios, '15.0'\n" + pf
    open('ios/Podfile', 'w', encoding='utf-8').write(pf)
except FileNotFoundError:
    pass

ip = 'ios/Runner/Info.plist'
pl = plistlib.load(open(ip, 'rb'))
pl['CFBundleDisplayName'] = name
pl['CFBundleName'] = name[:15]
pl['CFBundleDevelopmentRegion'] = 'ar'
pl['CFBundleLocalizations'] = ['ar', 'en']
pl['ITSAppUsesNonExemptEncryption'] = False

USE = {
    'NSCameraUsageDescription': 'يحتاج التطبيق الكاميرا لالتقاط الصور ومسح الرموز.',
    'NSPhotoLibraryUsageDescription': 'يحتاج التطبيق الوصول للصور لاختيارها.',
    'NSPhotoLibraryAddUsageDescription': 'يحتاج التطبيق حفظ الصور في المعرض.',
    'NSMicrophoneUsageDescription': 'يحتاج التطبيق الميكروفون للتسجيل والتعرف على الصوت.',
    'NSLocationWhenInUseUsageDescription': 'يحتاج التطبيق موقعك لعرض المعلومات القريبة منك.',
    'NSFaceIDUsageDescription': 'يستخدم التطبيق بصمة الوجه لحماية بياناتك.',
    'NSSpeechRecognitionUsageDescription': 'يحتاج التطبيق التعرف على الكلام لتحويل صوتك إلى نص.',
    'NSMotionUsageDescription': 'يحتاج التطبيق حساسات الحركة لعدّ الخطوات.',
    'NSBluetoothAlwaysUsageDescription': 'يحتاج التطبيق البلوتوث للاتصال بالأجهزة والطابعات.',
    'NFCReaderUsageDescription': 'يحتاج التطبيق NFC لقراءة البطاقات.',
}
NEEDS = {
    'image_picker': ['NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription', 'NSMicrophoneUsageDescription'],
    'camera': ['NSCameraUsageDescription', 'NSMicrophoneUsageDescription'],
    'mobile_scanner': ['NSCameraUsageDescription'],
    'qr_code_scanner_plus': ['NSCameraUsageDescription'],
    'geolocator': ['NSLocationWhenInUseUsageDescription'],
    'location': ['NSLocationWhenInUseUsageDescription'],
    'local_auth': ['NSFaceIDUsageDescription'],
    'speech_to_text': ['NSSpeechRecognitionUsageDescription', 'NSMicrophoneUsageDescription'],
    'record': ['NSMicrophoneUsageDescription'],
    'pedometer': ['NSMotionUsageDescription'],
    'sensors_plus': ['NSMotionUsageDescription'],
    'flutter_blue_plus': ['NSBluetoothAlwaysUsageDescription'],
    'print_bluetooth_thermal': ['NSBluetoothAlwaysUsageDescription'],
    'blue_thermal_printer': ['NSBluetoothAlwaysUsageDescription'],
    'nfc_manager': ['NFCReaderUsageDescription'],
    'gal': ['NSPhotoLibraryAddUsageDescription'],
    'image_gallery_saver_plus': ['NSPhotoLibraryAddUsageDescription'],
}
added = []
for d in sorted(deps):
    for k in NEEDS.get(d, []):
        if k not in pl:
            pl[k] = USE[k]
            added.append(k)
if deps & {'just_audio_background', 'audio_service'}:
    modes = set(pl.get('UIBackgroundModes', []))
    modes.add('audio')
    pl['UIBackgroundModes'] = sorted(modes)
    added.append('background audio')
if 'workmanager' in deps:
    modes = set(pl.get('UIBackgroundModes', []))
    modes.add('fetch')
    pl['UIBackgroundModes'] = sorted(modes)
if 'url_launcher' in deps:
    pl['LSApplicationQueriesSchemes'] = sorted(set(pl.get('LSApplicationQueriesSchemes', []) +
                                                   ['whatsapp', 'tel', 'mailto', 'sms', 'comgooglemaps', 'maps', 'https', 'http']))
plistlib.dump(pl, open(ip, 'wb'))
print('ios ready:', ios_id, name, 'v%d' % version, '| plist:', ', '.join(added) or '-')

"""Configure a fixed release signing key in a freshly created Flutter Android project.

Run from the Flutter project root. Reads the key from env vars at Gradle time:
KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD. Falls back to the debug key when the
keystore or env vars are missing (so the shared source still builds locally).
"""
import re
import sys

p = 'android/app/build.gradle.kts'
s = open(p, encoding='utf-8').read()

block = '''    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
'''
if '    buildTypes {' not in s:
    sys.exit('buildTypes block not found in ' + p)
s = s.replace('    buildTypes {', block + '    buildTypes {', 1)

s, n = re.subn(
    r'signingConfig = signingConfigs\.getByName\("debug"\)',
    'signingConfig = if (file("upload-keystore.jks").exists() && System.getenv("KEYSTORE_PASSWORD") != null) '
    'signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
    s)
if n < 1:
    sys.exit('release signingConfig line not found in ' + p)

open(p, 'w', encoding='utf-8').write(s)
print('release signing configured')

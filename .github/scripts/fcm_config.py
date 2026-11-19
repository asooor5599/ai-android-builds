"""Register the Android app in the user's Firebase project and write android/app/google-services.json.

usage: python3 fcm_config.py <app.json>      (run from the Flutter project root)
env:   FIREBASE_SA_JSON  service-account JSON (Firebase Admin role)
Prints only non-secret information. Exit code 0 + "FCM-OK" when the config was written.
"""
import json
import os
import sys
import time

import jwt
import requests

app = json.load(open(sys.argv[1], encoding='utf-8'))
pkg = app.get('appId') or ''
name = (app.get('appName') or pkg)[:50]


def die(msg):
    print('FCM-ERROR: ' + msg)
    print('::warning title=Firebase::' + msg)
    sys.exit(2)


raw = os.environ.get('FIREBASE_SA_JSON', '')
if app.get('pushDummy') and not raw:
    # test mode: syntactically valid config so the Gradle/Kotlin integration can be compiled without a real project
    cfg = {"project_info": {"project_number": "123456789012", "project_id": "aib-dummy", "storage_bucket": "aib-dummy.appspot.com"},
           "client": [{"client_info": {"mobilesdk_app_id": "1:123456789012:android:0123456789abcdef", "android_client_info": {"package_name": pkg}},
                       "oauth_client": [], "api_key": [{"current_key": "AIzaSyDUMMYDUMMYDUMMYDUMMYDUMMYDUMMY00"}],
                       "services": {"appinvite_service": {"other_platform_oauth_client": []}}}],
           "configuration_version": "1"}
    json.dump(cfg, open('android/app/google-services.json', 'w'))
    print('FCM-OK dummy config for', pkg)
    sys.exit(0)
if not raw:
    die('ملف حساب الخدمة غير موجود')
try:
    sa = json.loads(raw)
except Exception:
    die('ملف حساب الخدمة غير صالح')
pid = sa.get('project_id')
now = int(time.time())
assertion = jwt.encode({'iss': sa['client_email'], 'scope': 'https://www.googleapis.com/auth/firebase https://www.googleapis.com/auth/cloud-platform',
                        'aud': 'https://oauth2.googleapis.com/token', 'iat': now, 'exp': now + 3000},
                       sa['private_key'], algorithm='RS256', headers={'kid': sa.get('private_key_id')})
tok = requests.post('https://oauth2.googleapis.com/token', timeout=30,
                    data={'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'assertion': assertion})
if tok.status_code != 200:
    die('قوقل رفضت حساب الخدمة (%d)' % tok.status_code)
H = {'Authorization': 'Bearer ' + tok.json()['access_token']}
BASE = 'https://firebase.googleapis.com/v1beta1/projects/%s' % pid


def req(method, url, **kw):
    r = requests.request(method, url, headers=H, timeout=60, **kw)
    if r.status_code == 403:
        die('حساب الخدمة ما عنده صلاحية — أضف له دور Firebase Admin وفعّل Firebase Management API')
    if r.status_code >= 400:
        try:
            msg = r.json()['error']['message']
        except Exception:
            msg = r.text[:200]
        die('Firebase %s → %d: %s' % (url.split('/v1beta1/')[-1].split('?')[0], r.status_code, msg))
    return r.json() if r.content else {}


apps = req('GET', BASE + '/androidApps?pageSize=100').get('apps', [])
found = [a for a in apps if a.get('packageName') == pkg]
if found:
    app_id = found[0]['appId']
else:
    op = req('POST', BASE + '/androidApps', json={'packageName': pkg, 'displayName': name})
    for _ in range(30):
        if op.get('done'):
            break
        time.sleep(2)
        op = req('GET', 'https://firebase.googleapis.com/v1beta1/' + op['name'])
    if 'error' in op:
        die('تعذر تسجيل التطبيق في Firebase: ' + str(op['error'].get('message')))
    app_id = op.get('response', {}).get('appId')
    if not app_id:
        apps = req('GET', BASE + '/androidApps?pageSize=100').get('apps', [])
        found = [a for a in apps if a.get('packageName') == pkg]
        if not found:
            die('تعذر تسجيل التطبيق في Firebase')
        app_id = found[0]['appId']
import base64  # noqa: E402
cfg = req('GET', BASE + '/androidApps/%s/config' % app_id)
open('android/app/google-services.json', 'wb').write(base64.b64decode(cfg['configFileContents']))
print('FCM-OK', pid, pkg, 'registered' if not found else 'existing')

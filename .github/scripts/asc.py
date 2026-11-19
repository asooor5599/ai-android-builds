"""App Store Connect automation for the AI builder (Apple signing without manual steps).

Commands (all read ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8, APPLE_TEAM_ID from the environment):
  setup                     verify the API key, register devices (IOS_DEVICES json), create the distribution
                            certificate once and store it as repo secrets (needs GH_PAT + GITHUB_REPOSITORY)
  profile <bundle> <name> <adhoc|appstore> <out.mobileprovision>
                            ensure the bundle id exists and (re)create a provisioning profile; prints the profile name
  hasapp <bundle>           prints "yes" when an App Store Connect app record exists for the bundle id
Nothing secret is ever printed.
"""
import base64
import json
import os
import secrets
import subprocess
import sys
import tempfile
import time

import jwt
import requests

API = 'https://api.appstoreconnect.apple.com/v1'


def die(msg):
    print('ASC-ERROR: ' + msg)
    print('::error title=Apple::' + msg)
    with open(os.environ.get('GITHUB_STEP_SUMMARY', os.devnull), 'a') as f:
        f.write('### ❌ ' + msg + '\n')
    sys.exit(1)


def token():
    kid, iss, p8 = os.environ.get('ASC_KEY_ID', ''), os.environ.get('ASC_ISSUER_ID', ''), os.environ.get('ASC_KEY_P8', '')
    if not (kid and iss and p8):
        die('مفاتيح App Store Connect غير مكتملة')
    if 'BEGIN' not in p8:
        p8 = base64.b64decode(p8).decode()
    now = int(time.time())
    return jwt.encode({'iss': iss, 'iat': now, 'exp': now + 1100, 'aud': 'appstoreconnect-v1'}, p8, algorithm='ES256',
                      headers={'kid': kid, 'typ': 'JWT'})


H = None


def call(method, path, body=None, ok=(200, 201, 204)):
    global H
    if H is None:
        H = {'Authorization': 'Bearer ' + token(), 'Content-Type': 'application/json'}
    r = requests.request(method, API + path, headers=H, json=body, timeout=60)
    if r.status_code not in ok:
        try:
            err = r.json()['errors'][0]
            detail = '%s — %s' % (err.get('title', ''), err.get('detail', ''))
        except Exception:
            detail = r.text[:300]
        if r.status_code == 401:
            die('آبل رفضت المفتاح (401): تأكد من Key ID و Issuer ID وملف ‎.p8 وأن صلاحية المفتاح Admin أو App Manager')
        die('App Store Connect %s %s → %d: %s' % (method, path.split('?')[0], r.status_code, detail))
    return r.json() if r.content else {}


def seal_and_store(name, value):
    from nacl import encoding, public
    repo, pat = os.environ['GITHUB_REPOSITORY'], os.environ.get('GH_PAT', '')
    if not pat:
        die('GH_PAT غير موجود لحفظ الشهادة')
    gh = {'Authorization': 'Bearer ' + pat, 'Accept': 'application/vnd.github+json'}
    pk = requests.get('https://api.github.com/repos/%s/actions/secrets/public-key' % repo, headers=gh, timeout=30).json()
    box = public.SealedBox(public.PublicKey(pk['key'].encode(), encoding.Base64Encoder()))
    enc = base64.b64encode(box.encrypt(value.encode())).decode()
    r = requests.put('https://api.github.com/repos/%s/actions/secrets/%s' % (repo, name), headers=gh, timeout=30,
                     json={'encrypted_value': enc, 'key_id': pk['key_id']})
    if r.status_code not in (201, 204):
        die('تعذر حفظ السر %s في GitHub (%d)' % (name, r.status_code))


def setup():
    summary = []
    call('GET', '/apps?limit=1')
    summary.append('✅ مفتاح App Store Connect يعمل')
    # devices
    devices = json.loads(os.environ.get('IOS_DEVICES') or '[]')
    have = call('GET', '/devices?limit=200&filter[platform]=IOS')['data']
    known = {d['attributes']['udid'].upper() for d in have}
    added = 0
    for d in devices:
        udid = str(d.get('udid', '')).strip().upper()
        if udid and udid not in known:
            call('POST', '/devices', {'data': {'type': 'devices', 'attributes': {
                'name': str(d.get('name') or 'iPhone')[:50], 'udid': udid, 'platform': 'IOS'}}})
            added += 1
    summary.append('📱 الأجهزة المسجلة: %d (أضيف %d)' % (len(known) + added, added))
    # distribution certificate (created once; private key stays in GitHub secrets only)
    cert_id = os.environ.get('IOS_DIST_CERT_ID', '')
    valid = False
    if cert_id and os.environ.get('IOS_DIST_P12_B64'):
        r = requests.get(API + '/certificates/' + cert_id, headers=H, timeout=30)
        valid = r.status_code == 200
    if not valid:
        tmp = tempfile.mkdtemp()
        key, csr, cer, p12 = (os.path.join(tmp, n) for n in ('k.pem', 'r.csr', 'c.cer', 'c.p12'))
        subprocess.run(['openssl', 'genrsa', '-out', key, '2048'], check=True, capture_output=True)
        subprocess.run(['openssl', 'req', '-new', '-key', key, '-out', csr, '-subj', '/CN=AI Builder/O=AI Builder/C=SA'],
                       check=True, capture_output=True)
        csr_txt = open(csr).read()
        res = call('POST', '/certificates', {'data': {'type': 'certificates', 'attributes': {
            'certificateType': 'DISTRIBUTION', 'csrContent': csr_txt}}})
        content = base64.b64decode(res['data']['attributes']['certificateContent'])
        open(cer, 'wb').write(content)
        subprocess.run(['openssl', 'x509', '-inform', 'DER', '-in', cer, '-out', cer + '.pem'], check=True, capture_output=True)
        pw = secrets.token_hex(16)
        print('::add-mask::' + pw)
        subprocess.run(['openssl', 'pkcs12', '-export', '-legacy', '-inkey', key, '-in', cer + '.pem', '-out', p12, '-passout', 'pass:' + pw],
                       check=False, capture_output=True)
        if not os.path.exists(p12) or os.path.getsize(p12) == 0:
            subprocess.run(['openssl', 'pkcs12', '-export', '-inkey', key, '-in', cer + '.pem', '-out', p12, '-passout', 'pass:' + pw],
                           check=True, capture_output=True)
        seal_and_store('IOS_DIST_P12_B64', base64.b64encode(open(p12, 'rb').read()).decode())
        seal_and_store('IOS_DIST_P12_PASSWORD', pw)
        seal_and_store('IOS_DIST_CERT_ID', res['data']['id'])
        summary.append('🔐 أنشئت شهادة توزيع جديدة وحُفظت في أسرار GitHub')
    else:
        summary.append('🔐 شهادة التوزيع موجودة وصالحة')
    with open(os.environ.get('GITHUB_STEP_SUMMARY', os.devnull), 'a') as f:
        f.write('\n'.join('- ' + s for s in summary) + '\n')
    print('APPLE-SETUP-OK ' + ' | '.join(summary))


def profile(bundle, name, kind, out):
    r = call('GET', '/bundleIds?filter[identifier]=%s&limit=5' % bundle)['data']
    r = [b for b in r if b['attributes']['identifier'] == bundle]
    if r:
        bid = r[0]['id']
    else:
        bid = call('POST', '/bundleIds', {'data': {'type': 'bundleIds', 'attributes': {
            'identifier': bundle, 'name': ('AIB ' + name)[:60].encode('ascii', 'ignore').decode() or 'AIB App', 'platform': 'IOS'}}})['data']['id']
    pname = 'AIB %s %s' % ('AdHoc' if kind == 'adhoc' else 'AppStore', bundle)
    for p in call('GET', '/profiles?filter[name]=%s&limit=20' % requests.utils.quote(pname))['data']:
        call('DELETE', '/profiles/' + p['id'])
    rel = {'bundleId': {'data': {'type': 'bundleIds', 'id': bid}},
           'certificates': {'data': [{'type': 'certificates', 'id': os.environ['IOS_DIST_CERT_ID']}]}}
    if kind == 'adhoc':
        devs = call('GET', '/devices?limit=200&filter[platform]=IOS&filter[status]=ENABLED')['data']
        if not devs:
            die('لا توجد أجهزة مسجلة — أضف UDID الآيفون في صفحة «إعداد آبل»')
        rel['devices'] = {'data': [{'type': 'devices', 'id': d['id']} for d in devs]}
    res = call('POST', '/profiles', {'data': {'type': 'profiles', 'attributes': {
        'name': pname, 'profileType': 'IOS_APP_ADHOC' if kind == 'adhoc' else 'IOS_APP_STORE'}, 'relationships': rel}})
    open(out, 'wb').write(base64.b64decode(res['data']['attributes']['profileContent']))
    print(pname)


def hasapp(bundle):
    r = call('GET', '/apps?filter[bundleId]=%s&limit=1' % bundle)['data']
    print('yes' if r else 'no')


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'setup':
        setup()
    elif cmd == 'profile':
        profile(*sys.argv[2:6])
    elif cmd == 'hasapp':
        hasapp(sys.argv[2])
    else:
        die('unknown command')

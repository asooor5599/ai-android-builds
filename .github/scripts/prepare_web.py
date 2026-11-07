"""Prepare the Flutter web build as an installable iPhone web app (PWA).

Usage (from the Flutter project root):
  python3 prepare_web.py <app.json> <telemetry true|false>

- Sets the page title / iOS home-screen title / manifest name to the app name.
- Uses the splash color as theme/background color.
- Optionally injects a tiny anonymous usage-stats ping (same endpoint as Android).
"""
import html
import json
import re
import sys

app = json.load(open(sys.argv[1], encoding='utf-8'))
telemetry = sys.argv[2] == 'true'
name = (app.get('appName') or 'App').strip()[:30]
color = app.get('splashColor') or '#FFFFFF'
if not re.fullmatch(r'#[0-9A-Fa-f]{6}', color):
    color = '#FFFFFF'
app_id = app.get('appId') or ''
version = int(app.get('version') or 1)
ping = app.get('pingUrl') or ''

# ---- manifest.json
mp = 'web/manifest.json'
m = json.load(open(mp, encoding='utf-8'))
m.update({
    'name': name, 'short_name': name[:12], 'description': (app.get('summary') or name)[:200],
    'start_url': '.', 'scope': '.', 'display': 'standalone', 'orientation': 'portrait',
    'background_color': color, 'theme_color': color, 'lang': 'ar', 'dir': 'rtl',
})
json.dump(m, open(mp, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)

# ---- index.html
ip = 'web/index.html'
s = open(ip, encoding='utf-8').read()
safe = html.escape(name, quote=True)
s = re.sub(r'<title>.*?</title>', '<title>' + safe + '</title>', s, count=1, flags=re.S)
s = re.sub(r'(<meta name="apple-mobile-web-app-title" content=")[^"]*(")', r'\g<1>' + safe.replace('\\', '') + r'\2', s, count=1)
extra = ''
if 'apple-mobile-web-app-capable' not in s:
    extra += '  <meta name="apple-mobile-web-app-capable" content="yes">\n'
if 'name="theme-color"' not in s:
    extra += '  <meta name="theme-color" content="' + color + '">\n'

if telemetry and app_id and re.fullmatch(r'https://[A-Za-z0-9._/-]+', ping):
    js = r"""(function(){try{var E=%s,A=%s,V=%d,K='aib_'+A;
var d=new Date(Date.now()+3*3600e3).toISOString().slice(0,10);var s={};try{s=JSON.parse(localStorage.getItem(K)||'{}')}catch(e){}
if(s.day===d)return;
var u=s.uid||'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,function(c){var r=Math.random()*16|0;return(c=='x'?r:(r&3|8)).toString(16)});
var ua=navigator.userAgent,dev=/iPhone/.test(ua)?'iPhone':/iPad/.test(ua)?'iPad':/Android/.test(ua)?'Android':/Macintosh/.test(ua)?'Mac':'Web';
var inst=(window.navigator.standalone===true)||(window.matchMedia&&matchMedia('(display-mode: standalone)').matches);
fetch(E,{method:'POST',headers:{'Content-Type':'application/json','ngrok-skip-browser-warning':'1'},
body:JSON.stringify({app:A,vc:V,ev:s.uid?'open':'install',uid:u,sdk:0,p:'web',model:dev+(inst?' (Home screen)':' (Browser)')})})
.then(function(r){if(r.ok){try{localStorage.setItem(K,JSON.stringify({uid:u,day:d}))}catch(e){}}}).catch(function(){});
}catch(e){}})();""" % (json.dumps(ping), json.dumps(app_id), version)
    extra += '  <script>' + js + '</script>\n'

s = s.replace('</head>', extra + '</head>', 1)
open(ip, 'w', encoding='utf-8').write(s)
print('web prepared:', name, color, 'telemetry' if telemetry else 'no-telemetry')

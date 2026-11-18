"""Turn the AI-generated game files into a complete Godot 4 project.

usage: python3 godot_prepare.py <src dir> <project dir> <apk|web|preview>

<src>/game/*        -> the game files written by the AI (main.gd required, optional .gd/.tscn/.gdshader/.json)
<src>/app.json      -> name, appId, version, orientation, splashColor
<src>/icon.b64, splash.b64, assets_b64/*.b64 -> optional branding and uploaded files
Writes project.godot, export_presets.cfg, main.tscn (if missing), fonts, icon/splash and assets.
"""
import base64
import glob
import json
import os
import re
import shutil
import sys
import urllib.request

SRC, DST, MODE = sys.argv[1], sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else 'apk')
app = json.load(open(os.path.join(SRC, 'app.json'), encoding='utf-8'))
name = (app.get('appName') or 'My Game').strip()[:30]
app_id = app.get('appId') or 'com.aibuilder.game'
version = int(app.get('version') or 1)
landscape = str(app.get('orientation') or 'portrait') == 'landscape'
color = app.get('splashColor') or '#101820'
if not re.fullmatch(r'#[0-9A-Fa-f]{6}', color):
    color = '#101820'


def gcolor(h):
    return 'Color(%.3f, %.3f, %.3f, 1)' % tuple(int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))


def q(s):
    return '"' + str(s).replace('\\', '\\\\').replace('"', '\\"') + '"'


os.makedirs(DST, exist_ok=True)
gsrc = os.path.join(SRC, 'game')
for f in glob.glob(os.path.join(gsrc, '**', '*'), recursive=True):
    if os.path.isfile(f):
        rel = os.path.relpath(f, gsrc)
        if rel in ('project.godot', 'export_presets.cfg') or rel.startswith('.'):
            continue
        os.makedirs(os.path.dirname(os.path.join(DST, rel)) or DST, exist_ok=True)
        shutil.copyfile(f, os.path.join(DST, rel))

# main scene: generated from main.gd when the AI did not write main.tscn
if not os.path.exists(os.path.join(DST, 'main.tscn')):
    code = open(os.path.join(DST, 'main.gd'), encoding='utf-8').read()
    m = re.search(r'^extends\s+([A-Za-z0-9_]+)', code, flags=re.M)
    base = m.group(1) if m else 'Node'
    open(os.path.join(DST, 'main.tscn'), 'w', encoding='utf-8').write(
        '[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://main.gd" id="1"]\n\n'
        '[node name="Main" type="%s"]\nscript = ExtResource("1")\n' % base)

# Arabic fonts (default UI font + Quran font available to the code)
os.makedirs(os.path.join(DST, 'fonts'), exist_ok=True)
for path in ('tajawal/Tajawal-Regular.ttf', 'tajawal/Tajawal-Bold.ttf', 'amiri/Amiri-Regular.ttf'):
    dest = os.path.join(DST, 'fonts', os.path.basename(path))
    try:
        with urllib.request.urlopen('https://raw.githubusercontent.com/google/fonts/main/ofl/' + path, timeout=60) as r:
            open(dest, 'wb').write(r.read())
    except Exception as e:
        print('font download failed:', path, e)
has_font = os.path.exists(os.path.join(DST, 'fonts', 'Tajawal-Regular.ttf'))

# icon / splash / uploaded files
icon = splash = False
if os.path.exists(os.path.join(SRC, 'icon.b64')) and os.path.getsize(os.path.join(SRC, 'icon.b64')) > 100:
    open(os.path.join(DST, 'icon.png'), 'wb').write(base64.b64decode(open(os.path.join(SRC, 'icon.b64')).read()))
    icon = True
if app.get('splash') and os.path.exists(os.path.join(SRC, 'splash.b64')) and os.path.getsize(os.path.join(SRC, 'splash.b64')) > 100:
    open(os.path.join(DST, 'splash.png'), 'wb').write(base64.b64decode(open(os.path.join(SRC, 'splash.b64')).read()))
    splash = True
if not icon:
    # default icon: rounded tile in the theme color with a light "play" triangle
    import struct
    import zlib
    N = 256
    r0, g0, b0 = (int(color[i:i + 2], 16) for i in (1, 3, 5))
    rows = []
    for y in range(N):
        row = bytearray()
        for x in range(N):
            inside_tri = 90 <= x <= 180 and abs(y - 128) <= (x - 90) * 0.0 + (180 - x) * 0.55
            if inside_tri:
                row += bytes((255, 255, 255, 255))
            else:
                row += bytes((r0, g0, b0, 255))
        rows.append(b'\x00' + bytes(row))

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', N, N, 8, 6, 0, 0, 0)) + \
        chunk(b'IDAT', zlib.compress(b''.join(rows), 9)) + chunk(b'IEND', b'')
    open(os.path.join(DST, 'icon.png'), 'wb').write(png)
    icon = True
for f in sorted(glob.glob(os.path.join(SRC, 'assets_b64', '*.b64'))):
    n = os.path.basename(f)[:-4]
    if re.fullmatch(r'[A-Za-z0-9._-]{1,80}', n):
        os.makedirs(os.path.join(DST, 'assets'), exist_ok=True)
        open(os.path.join(DST, 'assets', n), 'wb').write(base64.b64decode(open(f).read()))

autoloads = ''
for a in app.get('autoloads') or []:
    if isinstance(a, dict) and re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]{0,40}', str(a.get('name', ''))) and \
            re.fullmatch(r'[a-z0-9_/]+\.(gd|tscn)', str(a.get('path', ''))) and os.path.exists(os.path.join(DST, a['path'])):
        autoloads += '%s="*res://%s"\n' % (a['name'], a['path'])

w, h = (1280, 720) if landscape else (720, 1280)
proj = '''config_version=5

[application]

config/name=%s
run/main_scene="res://main.tscn"
config/features=PackedStringArray("4.4", "GL Compatibility")
%sboot_splash/bg_color=%s
boot_splash/show_image=%s
%s
''' % (q(name), 'config/icon="res://icon.png"\n' if icon else '', gcolor(color), 'true' if splash else 'false',
       'boot_splash/image="res://splash.png"\nboot_splash/fullsize=false\n' if splash else '')
if autoloads:
    proj += '[autoload]\n\n' + autoloads + '\n'
proj += '''[display]

window/size/viewport_width=%d
window/size/viewport_height=%d
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=%d

''' % (w, h, 0 if landscape else 1)
if has_font:
    proj += '[gui]\n\ntheme/custom_font="res://fonts/Tajawal-Regular.ttf"\n\n'
proj += '''[input_devices]

pointing/emulate_touch_from_mouse=true

[internationalization]

locale/include_text_server_data=true

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
'''
open(os.path.join(DST, 'project.godot'), 'w', encoding='utf-8').write(proj)

inc = 'include_filter="*.json,*.txt,*.csv,*.cfg"\n'
presets = '''[preset.0]

name="Android"
platform="Android"
runnable=true
export_filter="all_resources"
%sexclude_filter=""
export_path=""

[preset.0.options]

gradle_build/use_gradle_build=false
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=%d
version/name="1.0.%d"
package/unique_name=%s
package/name=%s
package/signed=true
package/app_category=2
package/retain_data_on_uninstall=false
screen/immersive_mode=true
%spermissions/internet=true
permissions/vibrate=true

[preset.1]

name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
%sexclude_filter=""
export_path=""

[preset.1.options]

variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=true
html/export_icon=true
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
''' % (inc, version, version, q(app_id), q(name),
       ('launcher_icons/main_192x192="res://icon.png"\nlauncher_icons/adaptive_foreground_432x432="res://icon.png"\n' if icon else ''),
       inc)
open(os.path.join(DST, 'export_presets.cfg'), 'w', encoding='utf-8').write(presets)
print('godot project ready:', name, app_id, 'v%d' % version, 'landscape' if landscape else 'portrait',
      '| icon' if icon else '', '| splash' if splash else '', '| autoloads' if autoloads else '')

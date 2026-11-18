"""Bundle Arabic fonts used by the code + user-uploaded asset files (run from the Flutter project root).

usage: python3 fonts_assets.py <src dir>

- Fonts: any of the catalog families referenced in lib/ (e.g. fontFamily: 'Tajawal') are downloaded
  from the Google Fonts GitHub repo into assets/fonts and declared in pubspec.yaml.
- Assets: files uploaded from the page are stored base64 in <src>/assets_b64/<name>.b64; they are decoded
  into assets/files/<name> and declared in pubspec.yaml (code loads them as 'assets/files/<name>').
Safe to run on any project: does nothing when neither is used.
"""
import base64
import glob
import os
import re
import sys
import urllib.parse
import urllib.request

SRC = sys.argv[1] if len(sys.argv) > 1 else '../src'
BASE = 'https://raw.githubusercontent.com/google/fonts/main/ofl/'
FONTS = {
    'Cairo': [('cairo/Cairo[slnt,wght].ttf', None)],
    'Tajawal': [('tajawal/Tajawal-Regular.ttf', 400), ('tajawal/Tajawal-Medium.ttf', 500), ('tajawal/Tajawal-Bold.ttf', 700)],
    'Almarai': [('almarai/Almarai-Regular.ttf', 400), ('almarai/Almarai-Bold.ttf', 700)],
    'Amiri': [('amiri/Amiri-Regular.ttf', 400), ('amiri/Amiri-Bold.ttf', 700)],
    'Amiri Quran': [('amiriquran/AmiriQuran-Regular.ttf', None)],
    'Noto Naskh Arabic': [('notonaskharabic/NotoNaskhArabic[wght].ttf', None)],
    'Scheherazade New': [('scheherazadenew/ScheherazadeNew-Regular.ttf', 400), ('scheherazadenew/ScheherazadeNew-Bold.ttf', 700)],
    'Reem Kufi': [('reemkufi/ReemKufi[wght].ttf', None)],
    'El Messiri': [('elmessiri/ElMessiri[wght].ttf', None)],
    'Changa': [('changa/Changa[wght].ttf', None)],
    'Lalezar': [('lalezar/Lalezar-Regular.ttf', None)],
    'IBM Plex Sans Arabic': [('ibmplexsansarabic/IBMPlexSansArabic-Regular.ttf', 400), ('ibmplexsansarabic/IBMPlexSansArabic-Bold.ttf', 700)],
}

code = ''
for f in glob.glob('lib/**/*.dart', recursive=True):
    code += open(f, encoding='utf-8', errors='ignore').read()

used = [fam for fam in FONTS if re.search(r"['\"]%s['\"]" % re.escape(fam), code)]
font_yaml = ''
for fam in used:
    entries = ''
    for path, weight in FONTS[fam]:
        name = os.path.basename(path).replace('[', '_').replace(']', '').replace(',', '_')
        dest = 'assets/fonts/' + name
        os.makedirs('assets/fonts', exist_ok=True)
        try:
            url = BASE + urllib.parse.quote(path)
            with urllib.request.urlopen(url, timeout=60) as r, open(dest, 'wb') as out:
                out.write(r.read())
        except Exception as e:  # never fail the build because of a font
            print('font download failed:', fam, path, e)
            continue
        entries += '        - asset: %s\n' % dest + ('          weight: %d\n' % weight if weight else '')
    if entries:
        font_yaml += '    - family: %s\n      fonts:\n%s' % (fam, entries)

asset_names = []
for f in sorted(glob.glob(os.path.join(SRC, 'assets_b64', '*.b64'))):
    name = os.path.basename(f)[:-4]
    if not re.fullmatch(r'[A-Za-z0-9._-]{1,80}', name):
        continue
    os.makedirs('assets/files', exist_ok=True)
    try:
        open('assets/files/' + name, 'wb').write(base64.b64decode(open(f).read()))
        asset_names.append(name)
    except Exception as e:
        print('asset decode failed:', name, e)

if font_yaml or asset_names:
    pub = open('pubspec.yaml', encoding='utf-8').read()
    add = ''
    if asset_names:
        add += '  assets:\n    - assets/files/\n'
    if font_yaml:
        add += '  fonts:\n' + font_yaml
    pub, n = re.subn(r'(?m)^flutter:\s*\n', lambda m: m.group(0) + add, pub, count=1)
    if not n:
        pub += '\nflutter:\n' + add
    open('pubspec.yaml', 'w', encoding='utf-8').write(pub)
print('fonts:', used or '-', '| assets:', asset_names or '-')

"""Print the installed versions of the app's direct dependencies (read by the auto-fix) — run from the Flutter project root."""
import re
import sys

deps = []
try:
    deps = [l.strip() for l in open(sys.argv[1], encoding='utf-8') if l.strip()]
except Exception:
    pass
names = {re.split(r'[:\s]', d)[0] for d in deps}
lock = open('pubspec.lock', encoding='utf-8').read()
for name, ver in re.findall(r'\n  ([a-z0-9_]+):\n(?:    .*\n)*?    version: "([^"]+)"', lock):
    if name in names:
        print('AIB-VER %s %s' % (name, ver))

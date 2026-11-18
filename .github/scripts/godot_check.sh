#!/usr/bin/env bash
# Fast GDScript check: parse every script, then run the game headless for a few seconds.
# usage: godot_check.sh <godot binary>   (run from the Godot project dir)
GD="$1"
timeout 300 "$GD" --headless --import > /tmp/gd_import.log 2>&1 || true
ERR=""
for f in $(find . -name "*.gd" -not -path "./.godot/*" | sort); do
  out=$(timeout 60 "$GD" --headless --check-only --script "res://${f#./}" 2>&1 | grep -A1 "SCRIPT ERROR" | head -12)
  [ -n "$out" ] && ERR="$ERR$out"$'\n'
done
if [ -z "$ERR" ]; then
  ERR=$(timeout 90 "$GD" --headless --quit-after 300 2>&1 | grep -A1 -E "SCRIPT ERROR|Failed to load|Parse Error" | head -30)
fi
if [ -n "$ERR" ]; then
  echo "error: GDScript errors found:"
  echo "$ERR"
  echo "##[error]GDScript errors found"
  exit 1
fi
echo "GDScript check OK"

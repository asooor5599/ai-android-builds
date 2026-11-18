#!/usr/bin/env bash
# Install Godot + export templates (cached in ~/godot) and write editor settings for Android export.
set -e
V=4.4.1
GD=~/godot/Godot_v${V}-stable_linux.x86_64
if [ ! -x "$GD" ]; then
  mkdir -p ~/godot && cd ~/godot
  curl -sSL -o g.zip "https://github.com/godotengine/godot/releases/download/${V}-stable/Godot_v${V}-stable_linux.x86_64.zip"
  unzip -oq g.zip && rm g.zip
  curl -sSL -o t.tpz "https://github.com/godotengine/godot/releases/download/${V}-stable/Godot_v${V}-stable_export_templates.tpz"
  unzip -oq t.tpz 'templates/android_release.apk' 'templates/android_debug.apk' 'templates/web_nothreads_release.zip' 'templates/version.txt' -d tpl && rm t.tpz
  cd - > /dev/null
fi
mkdir -p ~/.local/share/godot/export_templates/${V}.stable
cp ~/godot/tpl/templates/* ~/.local/share/godot/export_templates/${V}.stable/
[ -f ~/godot/debug.keystore ] || keytool -genkeypair -v -keystore ~/godot/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" > /dev/null 2>&1
mkdir -p ~/.config/godot
cat > ~/.config/godot/editor_settings-4.4.tres <<EOT
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
export/android/java_sdk_path = "${JAVA_HOME}"
export/android/debug_keystore = "$HOME/godot/debug.keystore"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
EOT
echo "GD=$GD" >> "$GITHUB_ENV"
"$GD" --headless --version

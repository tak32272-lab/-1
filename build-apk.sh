#!/bin/bash
# Gradle を使わずに aapt2 / d8 / apksigner で debug APK をビルドするスクリプト。
# 必要: JDK 17, Android platform android-34, build-tools 34.0.0
set -e
JAVA_HOME="${JAVA_HOME:?JAVA_HOME を JDK17 に設定してください}"
export PATH="$JAVA_HOME/bin:$PATH"
SDK="${ANDROID_HOME:-$HOME/android-sdk}"
BT="$SDK/build-tools/34.0.0"
AJAR="$SDK/platforms/android-34/android.jar"
PROJ="$(cd "$(dirname "$0")" && pwd)"
B="$(mktemp -d)"

javac --release 8 -cp "$AJAR" -d "$B/classes" \
  "$PROJ/app/src/main/java/com/ke/sectest/MainActivity.java"
(cd "$B" && jar cf classes.jar -C classes .)
"$BT/d8" --lib "$AJAR" --output "$B/dex" "$B/classes.jar"
"$BT/aapt2" compile -o "$B/res.zip" --dir "$PROJ/app/src/main/res"
"$BT/aapt2" link -o "$B/unsigned.apk" -I "$AJAR" \
  --manifest "$PROJ/app/src/main/AndroidManifest.xml" \
  -A "$PROJ/app/src/main/assets" -R "$B/res.zip" \
  --min-sdk-version 26 --target-sdk-version 34 \
  --version-code 1 --version-name 1.0
(cd "$B" && cp dex/classes.dex . && zip -q unsigned.apk classes.dex)
"$BT/zipalign" -f -p 4 "$B/unsigned.apk" "$B/aligned.apk"
KS="${DEBUG_KEYSTORE:-$HOME/workspace/tools/debug.keystore}"
if [ ! -f "$KS" ]; then
  keytool -genkeypair -keystore "$KS" -storepass android -keypass android \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
  --out "$PROJ/security-test-simulator.apk" "$B/aligned.apk"
"$BT/apksigner" verify "$PROJ/security-test-simulator.apk"
echo "OK: $PROJ/security-test-simulator.apk"

#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 <unsigned.ipa> <signed.ipa> <signing-identity> <profile.mobileprovision>"
    echo "Example: $0 build/xcloud-ultra-unsigned.ipa build/xcloud-ultra-signed.ipa \"Apple Distribution: Example, Inc. (TEAMID)\" ~/Library/MobileDevice/Provisioning\ Profiles/XCloud.mobileprovision"
    exit 2
}

[ "$#" -eq 4 ] || usage
INPUT_IPA="$1"
OUTPUT_IPA="$2"
SIGNING_IDENTITY="$3"
PROFILE="$4"

[ -f "$INPUT_IPA" ] || { echo "❌ IPA not found: $INPUT_IPA"; exit 1; }
[ -f "$PROFILE" ] || { echo "❌ Provisioning profile not found: $PROFILE"; exit 1; }
command -v codesign >/dev/null 2>&1 || { echo "❌ codesign is required on macOS"; exit 1; }

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
unzip -q "$INPUT_IPA" -d "$TMP_DIR"
APP_PATH=$(find "$TMP_DIR/Payload" -maxdepth 1 -type d -name "*.app" -print -quit)
[ -n "$APP_PATH" ] || { echo "❌ No app bundle found in IPA"; exit 1; }

PROFILE_PLIST="$TMP_DIR/profile.plist"
ENTITLEMENTS="$TMP_DIR/entitlements.plist"
security cms -D -i "$PROFILE" > "$PROFILE_PLIST"
plutil -extract Entitlements xml1 -o "$ENTITLEMENTS" "$PROFILE_PLIST"
cp "$PROFILE" "$APP_PATH/embedded.mobileprovision"

echo "Signing nested code..."
find "$APP_PATH" ( -name "*.framework" -o -name "*.appex" -o -name "*.dylib" ) -print0 | while IFS= read -r -d "" item; do
    codesign --force --sign "$SIGNING_IDENTITY" --timestamp=none "$item"
done

echo "Signing app bundle..."
codesign --force --sign "$SIGNING_IDENTITY" --entitlements "$ENTITLEMENTS" --timestamp=none "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

OUTPUT_DIR=$(cd "$(dirname "$OUTPUT_IPA")" && pwd)
OUTPUT_PATH="$OUTPUT_DIR/$(basename "$OUTPUT_IPA")"
rm -f "$OUTPUT_PATH"
( cd "$TMP_DIR" && zip -qry "$OUTPUT_PATH" Payload )
shasum -a 256 "$OUTPUT_PATH" > "$OUTPUT_PATH.sha256"
echo "✓ Signed IPA: $OUTPUT_PATH"
echo "✓ SHA256: $(cat "$OUTPUT_PATH.sha256")"

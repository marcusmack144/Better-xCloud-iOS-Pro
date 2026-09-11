#!/bin/bash
set -euo pipefail

PROJECT_DIR="XCloudUltra"
PROJECT_NAME="XCloudUltra"
SCHEME="XCloudUltra"
BUILD_DIR="build"
DERIVED_DATA="${BUILD_DIR}/derived"
CONFIGURATION="Release"
SDK="iphoneos"
ARCH="arm64"

echo "🔨 Starting iOS IPA build for ${PROJECT_NAME}"

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "❌ XcodeGen is required. Install it with: brew install xcodegen"
    exit 1
fi
if [ ! -f "${PROJECT_DIR}/project.yml" ]; then
    echo "❌ XcodeGen spec not found at ${PROJECT_DIR}/project.yml"
    exit 1
fi

echo "Generating Xcode project..."
( cd "${PROJECT_DIR}" && xcodegen generate --spec "${PWD}/project.yml" )

echo "Cleaning previous build artifacts..."
rm -rf "${DERIVED_DATA}"
mkdir -p "${BUILD_DIR}"

echo "Building unsigned app for release..."
xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA}" \
    -sdk "${SDK}" \
    -arch "${ARCH}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    IPHONEOS_DEPLOYMENT_TARGET="16.0" \
    -verbose 2>&1 | tee build.log

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.app"
if [ ! -d "${APP_PATH}" ]; then
    echo "❌ Build failed: app not found at ${APP_PATH}"
    find "${DERIVED_DATA}/Build/Products" -type d -name "*.app" || true
    exit 1
fi

echo "Creating IPA payload..."
IPA_PAYLOAD="${BUILD_DIR}/Payload"
IPA_NAME="xcloud-ultra-unsigned.ipa"
rm -rf "${IPA_PAYLOAD}" "${BUILD_DIR}/${IPA_NAME}"
mkdir -p "${IPA_PAYLOAD}"
cp -R "${APP_PATH}" "${IPA_PAYLOAD}/"
find "${IPA_PAYLOAD}" -name "*.swiftmodule" -type d -exec rm -rf {} + 2>/dev/null || true
find "${IPA_PAYLOAD}" -name "*.modulemap" -delete 2>/dev/null || true
find "${IPA_PAYLOAD}" -name ".DS_Store" -delete 2>/dev/null || true

( cd "${BUILD_DIR}" && zip -r -q "${IPA_NAME}" Payload/ )
IPA_PATH="${BUILD_DIR}/${IPA_NAME}"
if [ ! -f "${IPA_PATH}" ]; then
    echo "❌ IPA creation failed"
    exit 1
fi

shasum -a 256 "${IPA_PATH}" > "${IPA_PATH}.sha256"
echo "✓ IPA created: ${IPA_PATH}"
echo "✓ SHA256: $(cat "${IPA_PATH}.sha256")"
echo "Unsigned IPAs must be signed with your Apple account before installation."

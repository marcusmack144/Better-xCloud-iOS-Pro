#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Better-xCloud-iOS-Pro"
SCHEME="Better-xCloud-iOS-Pro"
WORKSPACE="${PROJECT_NAME}.xcworkspace"
BUILD_DIR="build"
DERIVED_DATA="${BUILD_DIR}/derived"
CONFIGURATION="Release"
SDK="iphoneos"
ARCH="arm64"

echo -e "${YELLOW}🔨 Starting iOS IPA Build for ${PROJECT_NAME}${NC}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous build artifacts...${NC}"
rm -rf "${DERIVED_DATA}"
mkdir -p "${BUILD_DIR}"

# Install dependencies
echo -e "${YELLOW}Installing CocoaPods dependencies...${NC}"
if [ -f "Podfile" ]; then
    pod install --repo-update || true
fi

# Build the app
echo -e "${YELLOW}Building app for release...${NC}"
xcodebuild \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA}" \
    -sdk "${SDK}" \
    -arch "${ARCH}" \
    -verbose \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO 2>&1 | tee build.log

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphoneos/${SCHEME}.app"

if [ ! -d "${APP_PATH}" ]; then
    echo -e "${RED}❌ Build failed: App not found at ${APP_PATH}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ App built successfully${NC}"

# Create IPA payload
echo -e "${YELLOW}Creating IPA package structure...${NC}"
IPA_PAYLOAD="${BUILD_DIR}/Payload"
IPA_NAME="${PROJECT_NAME}.ipa"

rm -rf "${IPA_PAYLOAD}"
mkdir -p "${IPA_PAYLOAD}"
cp -r "${APP_PATH}" "${IPA_PAYLOAD}/"

# Optimize app size
echo -e "${YELLOW}Optimizing app bundle...${NC}"
find "${IPA_PAYLOAD}" -name "*.swiftmodule" -type d -exec rm -rf {} + 2>/dev/null || true
find "${IPA_PAYLOAD}" -name "*.modulemap" -delete 2>/dev/null || true

# Create IPA
echo -e "${YELLOW}Compressing IPA...${NC}"
cd "${BUILD_DIR}" && zip -r -q "${IPA_NAME}" Payload/ && cd ..

IPA_PATH="${BUILD_DIR}/${IPA_NAME}"

if [ -f "${IPA_PATH}" ]; then
    IPA_SIZE=$(du -h "${IPA_PATH}" | cut -f1)
    echo -e "${GREEN}✓ IPA created successfully: ${IPA_PATH} (${IPA_SIZE})${NC}"
else
    echo -e "${RED}❌ IPA creation failed${NC}"
    exit 1
fi

# Generate checksum for verification
echo -e "${YELLOW}Generating checksums...${NC}"
sha256sum "${IPA_PATH}" > "${BUILD_DIR}/${IPA_NAME}.sha256"
md5sum "${IPA_PATH}" > "${BUILD_DIR}/${IPA_NAME}.md5"

echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${YELLOW}Output:${NC}"
echo "  IPA: ${IPA_PATH}"
echo "  SHA256: $(cat ${BUILD_DIR}/${IPA_NAME}.sha256)"
echo "  MD5: $(cat ${BUILD_DIR}/${IPA_NAME}.md5)"

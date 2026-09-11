#!/bin/bash
set -euo pipefail

# Better xCloud pinned version
COMMIT="f8397043f6d2148d2345d508902a38c69cf1ee20"
VERSION="6.7.12"
GITHUB_RAW="https://raw.githubusercontent.com/redphx/better-xcloud/${COMMIT}/dist/better-xcloud.user.js"

RESOURCES_DIR="${PROJECT_DIR}/XCloudUltra/Resources"
SCRIPT_FILE="${RESOURCES_DIR}/better-xcloud.user.js"

mkdir -p "${RESOURCES_DIR}"

echo "Downloading Better xCloud ${VERSION} (commit ${COMMIT:0:7})..."

if curl -fsSL "${GITHUB_RAW}" -o "${SCRIPT_FILE}"; then
    # Verify the script contains expected version string
    if grep -q "// @version.*${VERSION}" "${SCRIPT_FILE}"; then
        echo "✓ Better xCloud ${VERSION} downloaded successfully"
    else
        echo "❌ Version mismatch in downloaded script"
        exit 1
    fi
else
    echo "❌ Failed to download Better xCloud"
    exit 1
fi

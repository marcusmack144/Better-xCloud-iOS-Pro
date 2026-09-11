# xCloud Ultra - Native iOS Client

A minimal, native WKWebView-based Xbox Cloud Gaming (xCloud) client for iOS with embedded Better xCloud userscript.

**Build entirely in GitHub Actions. No signing credentials required for unsigned IPA.**

---

## What This Is

- ✅ Native Swift/UIKit app wrapping WKWebView
- ✅ Persistent WebKit storage (shared process pool, default data store)
- ✅ Better xCloud 6.7.12 injected at document start
- ✅ Minimal native bridge (AppInterface) for essential features only
- ✅ Unsigned IPA built and packaged by GitHub Actions
- ✅ Ready for your signing service (AltStore, Sideloadly, etc.)

**What This Is NOT**

- ❌ No custom controller polling bridge
- ❌ No synthetic input injection
- ❌ No custom WebRTC implementation
- ❌ No native performance overlays or debug HUD
- ❌ No fake "0ms latency" or "120Hz" claims
- ❌ No analytics, telemetry, or crash reporting
- ❌ No private APIs or jailbreak support

---

## Architecture

```
iOS Device (USB-C Xbox Controller)
         ↓
    WebKit Gamepad API
         ↓
    navigator.getGamepads()
         ↓
    Better xCloud (6.7.12)
         ↓
    WebRTC → Video Rendering
```

**Single input path.** No duplication. No bridge.

The native layer is purely a container:
- Loads `xbox.com/play` in WKWebView
- Injects Better xCloud userscript at document start
- Provides minimal native methods only when Better xCloud explicitly calls them
- Stays out of the input/WebRTC pipeline

---

## System Requirements

- **iOS:** 16.0+
- **Architecture:** arm64 (iPhone 12+, iPhone SE 3rd gen+)
- **Xbox Cloud Gaming:** Active account + supported region
- **Network:** Stable connection (5 GHz Wi-Fi recommended)
- **Controller:** Any gamepad supported by iOS (Xbox Series controller recommended)

---

## Download & Install

### Step 1: Get the Unsigned IPA

1. Go to **Actions** in this repository
2. Find the latest **Build Unsigned IPA** workflow run
3. Under **Artifacts**, download **xcloud-ultra-unsigned-ipa**
4. Extract the `.ipa` file

### Step 2: Sign & Install

Choose one:

#### Option A: AltStore (Recommended, Free)

1. Install **AltServer** on macOS or Windows
2. Open **AltServer**, connect your iPhone
3. Select your device → **Install AltStore**
4. On iPhone: **Settings → General → VPN & Device Management** → Trust the profile
5. Open **AltStore** on iPhone → **My Apps → +** → select the `.ipa`
6. Wait for installation

> **Note:** Free Apple ID requires re-signing every ~7 days. Paid developer accounts last up to 12 months.

#### Option B: Sideloadly

1. Download **Sideloadly** for Windows/macOS
2. Connect your iPhone via USB
3. Drag the `.ipa` into Sideloadly
4. Sign with your Apple ID
5. Install

#### Option C: Your Own Signing Service

The unsigned IPA is ready for any third-party signing tool you prefer.

---

## Building Locally (Optional)

Requires: macOS 13.0+, Xcode 15.0+, Homebrew

```bash
# Clone this repo
git clone https://github.com/marcusmack144/Better-xCloud-iOS-Pro.git
cd Better-xCloud-iOS-Pro

# Install XcodeGen
brew install xcodegen

# Run build script
chmod +x scripts/build-ipa.sh
./scripts/build-ipa.sh
```

Output: `build/xcloud-ultra-unsigned.ipa`

---

## How It Works

### Native Layer (Swift)

- **XCloudUltraApp.swift** — Main entry point
- **XCloudWebViewContainer.swift** — UIViewController hosting WKWebView
- **WebViewConfiguration.swift** — Centralized WKWebView config factory
  - Shared process pool (app lifetime)
  - Persistent data store (default)
  - Better xCloud injection at document start
- **AppInterface.swift** — Minimal native bridge
  - Handles `vibrate()` calls (haptic feedback)
  - Handles `closeApp()` requests
  - Does NOT poll controller state
  - Does NOT inject controller events
  - Does NOT modify navigator.getGamepads()

### Better xCloud Integration

- **Pinned version:** 6.7.12 (commit: `f8397043f6d2148d2345d508902a38c69cf1ee20`)
- **Injection:** WKUserScript at `atDocumentStart`
- **Storage:** GitHub Actions downloads during build, verified during CI
- **Userscript:** Embedded in IPA as `Resources/better-xcloud.user.js`

### Gamepad Input Path

1. Xbox Series controller connects via USB-C
2. iOS recognizes via GameController framework
3. **WebKit handles native Gamepad API internally**
4. JavaScript calls `navigator.getGamepads()`
5. Better xCloud reads button/stick state
6. WebRTC stream receives input commands

**No native polling loop. No bridge. No duplication.**

---

## GitHub Actions Build

The repository includes a complete CI workflow (`.github/workflows/build.yml`):

1. ✓ Checks out code
2. ✓ Installs XcodeGen
3. ✓ Downloads & verifies Better xCloud 6.7.12
4. ✓ Generates Xcode project from `project.yml`
5. ✓ Builds unsigned IPA for arm64
6. ✓ Validates IPA structure
7. ✓ Uploads to Actions artifacts
8. ✓ Generates SHA256 checksum

**No signing secrets required.** Build works as-is.

---

## Configuration

### App Settings

Edit `XCloudUltra/project.yml`:

```yaml
PRODUCT_BUNDLE_IDENTIFIER: poshgator.better-xcloud
MARKETING_VERSION: "1.0"
CURRENT_PROJECT_VERSION: "1"
IPHONEOS_DEPLOYMENT_TARGET: "16.0"
```

### Better xCloud Version

Edit `scripts/download-better-xcloud.sh`:

```bash
COMMIT="f8397043f6d2148d2345d508902a38c69cf1ee20"  # Git commit hash
VERSION="6.7.12"                                     # Version string to verify
```

Change these to pin a different Better xCloud build. CI will verify the version during build.

---

## Known Limitations

- **Feature availability** depends on Microsoft's xCloud site and your region
- **Connection quality** depends on your network (not the app)
- **Gamepad support** varies by iOS device; USB-C wired controllers are most reliable
- **Re-signing** required ~every 7 days with free Apple IDs

---

## Privacy & Security

- **No data collection.** The app does not track usage, collect analytics, or send telemetry.
- **No modifications to Xbox services.** Network traffic goes directly to Microsoft's domains.
- **Local only.** Better xCloud runs entirely in WebKit; no external injection or monitoring.
- **Permissions.** App requests only:
  - Network access (for xCloud)
  - Local network access (for controller/device discovery)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Blank screen / stuck loading** | Kill app, relaunch. Check network. Try signing out/in at xbox.com/play. |
| **Controller not recognized** | Reconnect controller. Restart app. Ensure iOS 16.0+. |
| **Script error in console** | Cross-origin CORS errors are normal in WKWebView; harmless for third-party scripts. |
| **App crashes on launch** | Ensure you've installed via AltStore/Sideloadly correctly. Try reinstalling. |
| **IPA won't install** | Verify your signing method is correct for your device. Check device trust settings. |

---

## License & Credits

- **App code:** Provided as-is. Build and modify for personal use.
- **Better xCloud:** [redphx/better-xcloud](https://github.com/redphx/better-xcloud) — MIT licensed
- **Xbox/xCloud:** Trademarks of Microsoft Corporation

This project is **not** affiliated with, endorsed by, or sponsored by Microsoft or Xbox.

---

## Support

- **App issues:** Open an Issue on this repository
- **Better xCloud issues:** See [redphx/better-xcloud/issues](https://github.com/redphx/better-xcloud/issues)
- **Signing issues:** Consult AltStore/Sideloadly documentation

---

## Contributing

Pull requests welcome. Keep changes focused:
- Thin native layer only
- No redundant controller polling
- No synthetic input injection
- No fake performance claims

---

Built with Swift, WebKit, and Better xCloud.

Optimized by removing unnecessary work, not adding layers.

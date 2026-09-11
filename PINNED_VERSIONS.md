# Pinned Dependencies

## Better xCloud
- **Version:** 6.7.12
- **Commit:** f8397043f6d2148d2345d508902a38c69cf1ee20
- **Date:** July 14, 2026
- **Repository:** https://github.com/redphx/better-xcloud
- **License:** MIT

## iOS Build Target
- **Minimum iOS:** 16.0
- **Architecture:** arm64
- **Xcode Version:** 15.0+
- **Swift Version:** 5.9+

## How to Update Better xCloud

Edit `scripts/download-better-xcloud.sh`:

```bash
COMMIT="<new-commit-hash>"
VERSION="<new-version>"
```

The CI will verify the version during build and fail if it doesn't match.

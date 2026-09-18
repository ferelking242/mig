---
name: CI Flutter version
description: Flutter and Dart compatibility constraint for the GitHub build.
---

The CI workflow must use a Flutter release whose bundled Dart SDK is at least 3.9.0.

**Why:** The git-based video player dependency rejects Dart 3.8 during dependency resolution.

**How to apply:** Keep the Flutter version in the GitHub Action on a stable release with Dart 3.9 or newer before changing the video-player dependency.
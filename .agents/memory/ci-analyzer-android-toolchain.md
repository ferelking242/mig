---
name: CI analyzer and Android toolchain
description: Durable CI constraints for Dart diagnostics and Android dependency resolution
---

Use `dart analyze --format machine` for machine-readable diagnostics; `flutter analyze` does not accept that format flag. Treat analyzer exit code 2 as warning-only when no `ERROR|` records are present.

**Why:** Flutter CI needed annotations without blocking release builds on existing warnings, while analyzer command behavior differed from the Dart analyzer.

When dependency resolution advances AndroidX libraries, verify AAR metadata requirements and update the Android Gradle Plugin and Gradle wrapper together rather than relying on an older project toolchain.

**Why:** Resolved AndroidX versions can require a newer AGP even when the Dart dependency declarations did not change.

**How to apply:** Check the first failing Gradle task and its required AGP version; keep `android/settings.gradle`, `android/build.gradle`, and the wrapper version synchronized.
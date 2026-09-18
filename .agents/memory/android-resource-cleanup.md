---
name: Android resource cleanup
description: Release-build lint behavior when removing native Android features
---

When removing a native Android feature, delete its base resources and every
configuration-qualified variant together. Android release lint reports a
`MissingDefaultResource` error when a `values-sw600dp` resource survives after
its base `values` declaration is removed.

**Why:** Removing the widget feature exposed this only during `lintVitalRelease`,
after the first CI build had already reached the Android release stage.

**How to apply:** Search all `android/app/src/main/res/values-*` directories for
resource names belonging to the removed feature before pushing a release build.
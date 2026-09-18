# MIG

MIG is the standalone FlixQuest application extracted from Watchtower.

## Scope

- Keeps the real FlixQuest movie, series, profile, settings, player and
  Android TV screens.
- Removes the Watchtower fixture-backed migration preview.
- Removes the design-only mockup folders.
- Builds directly from a clean checkout using the public
  `better_player_plus` Git dependency.

## Build locally

```bash
printf '' > .env
flutter pub get
flutter build apk --release --target-platform android-arm64
```

The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`.

## GitHub build

Use the **Build MIG ARM64** workflow to produce an installable ARM64 APK
artifact for device testing.
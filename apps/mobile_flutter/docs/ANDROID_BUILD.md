# Android build

## Local toolchain

The current development machine uses a user-local toolchain (no root required):

| Tool | Path |
|---|---|
| Java 21 (Temurin) | `~/.local/share/mise/installs/java/21.0.13+9.0.LTS` |
| Android SDK | `~/.local/share/android-sdk` |
| Build tools | `36.0.0` |
| Platform | `android-36` |
| NDK | `28.2.13676358` |

`~/.bashrc` exports `ANDROID_HOME` and adds `cmdline-tools` + `platform-tools` to `PATH`.

## Build a release APK

```bash
cd apps/mobile_flutter
flutter pub get
flutter build apk --release
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

The release build is currently signed with the **debug keystore** so it can be
installed for testing. Before publishing to Google Play, configure a private
release keystore in `android/app/build.gradle.kts`.

## Install on a phone

Option A — USB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Option B — transfer the APK to the phone and open it. Android will ask to allow
installation from unknown sources.

## Notes

- `minSdk` is 24 (Android 7.0+).
- The app is fully offline in the current milestone; network permissions will be
  added with the API integration.
- The launch screen is branded: `#0A0A0A` background with the Suppercook icon.

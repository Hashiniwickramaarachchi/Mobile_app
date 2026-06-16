Release signing and APK build

This document shows how to generate a keystore, populate `key.properties`, and build a signed release APK.

1) Create a secure keystore (uses Java `keytool`)

- Open an elevated terminal and run (adjust paths and alias as needed):

```powershell
mkdir -p android/keystore
keytool -genkeypair -v \
  -keystore android/keystore/myapp.keystore \
  -storetype PKCS12 \
  -alias myappkey \
  -keyalg RSA -keysize 2048 -validity 10000
```

You will be prompted for passwords and owner info. Keep the passwords safe.

2) Edit `android/key.properties`

- Fill these values (do NOT commit real secrets to source control):

```
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=myappkey
storeFile=../keystore/myapp.keystore
```

`storeFile` is relative to `android/` and points to the keystore file created above.

3) Build the signed APK

From the workspace root:

```powershell
cd Mobile
flutter clean
flutter pub get
flutter build apk --release
```

If `key.properties` is present the Gradle config will use it to sign the release build. The output APK will be at:

```
Mobile/build/app/outputs/flutter-apk/app-release.apk
```

4) Optional: Verify the APK signature

Using the Android `apksigner` (part of Android SDK build-tools):

```powershell
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

5) If you prefer an App Bundle (recommended for Play Store):

```powershell
flutter build appbundle --release
```

Notes & troubleshooting

- Make sure Java 11+ (JDK 17 recommended) is installed and available in your PATH when running Gradle.
- If you need me to generate a keystore and run the build here, I can do that with temporary test passwords (not recommended for production). Otherwise supply your `key.properties` or follow the steps above and I'll build the signed APK.

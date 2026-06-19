# Release Setup

This project is now wired for production-style Android signing.

## Android

Files:

- `android/key.properties`
- `android/key.properties.example`
- `android/app/upload-keystore.jks`

`android/key.properties` should contain:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

### Generate a keystore manually

```bash
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Then copy `android/key.properties.example` to `android/key.properties` and fill in the real values.

### Build commands

```bash
flutter build apk --release
flutter build appbundle --release
```

## iOS

iOS bundle ID has been updated to match the app branding, but Apple signing still has to be completed in Xcode with:

- your Apple Developer team
- signing certificate
- provisioning profile

Open `ios/Runner.xcworkspace` in Xcode and complete signing under the `Runner` target.

## Backup

Back up these files securely:

- `android/app/upload-keystore.jks`
- `android/key.properties`

If you lose the Android upload keystore, you can lose the ability to ship updates under the same Play Store app.

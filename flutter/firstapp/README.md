# mesibo Flutter First App

The First App is a small mesibo app: two users log in and send each other messages and voice and
video calls. It comes with the mesibo Flutter SDK as its example app, so there is nothing else to
download.

## Requirements

- Flutter 3.44 or later
- iOS 15 or later; the iOS simulator needs a Mac with Apple silicon
- Android 7.0 (API 24) or later
- A mesibo account: https://console.mesibo.com

## 1. Get the app

Download the mesibo package from pub.dev. The app is in its `example` folder:

```bash
dart pub unpack mesibo
cd mesibo-*/example
flutter pub get
```

## 2. Create two users

A user token works only for the App ID it was created with. The First App's App ID is
`com.mesibo.flutter.example` on both Android and iOS, so the same tokens work on both.

In the mesibo console, create an app, then create two users with the App ID
`com.mesibo.flutter.example`. Note each user's address and token. For details, see
https://docs.mesibo.com/tutorials/get-started/

If you change the App ID (`applicationId` in `android/app/build.gradle`, Bundle Identifier of the
Runner target on iOS), change it on both platforms and create the tokens with the new one.

## 3. Run

Pass the tokens and addresses when you run the app, so that they are not in the source code:

```bash
flutter run --dart-define=USER1_TOKEN=<token> --dart-define=USER1_ADDRESS=<address> \
            --dart-define=USER2_TOKEN=<token> --dart-define=USER2_ADDRESS=<address>
```

Run it on two devices or simulators. Log in as User-1 on one and as User-2 on the other, then
message and call the other user.

## Troubleshooting

- **The token is invalid:** the token was created with a different App ID. Create it with
  `com.mesibo.flutter.example`.
- **iOS build fails on the simulator with `flutter build ios --simulator`:** the mesibo iOS SDK
  supports arm64 simulators only. `flutter run` works; for a build, set
  `EXCLUDED_ARCHS[sdk=iphonesimulator*] = x86_64` in the Runner target.
- **Calls don't work on a simulator:** use real devices for calls, which need a camera and a
  microphone.

## Next steps

- Add mesibo to your own app: https://pub.dev/packages/mesibo
- Documentation: https://docs.mesibo.com

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for fuchsia.',
        );
    }
  }

  // Web and desktop reuse the Firebase project credentials already present
  // in the repository. Replace this appId if you later register a dedicated
  // web app in Firebase.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmDey9IuyNtb85Vu7e1-ePsuOYeJU6o94',
    appId: '1:1067652500057:android:3206368ca373f5476b3f48',
    messagingSenderId: '1067652500057',
    projectId: 'nutriday-a61b5',
    authDomain: 'nutriday-a61b5.firebaseapp.com',
    storageBucket: 'nutriday-a61b5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmDey9IuyNtb85Vu7e1-ePsuOYeJU6o94',
    appId: '1:1067652500057:android:3206368ca373f5476b3f48',
    messagingSenderId: '1067652500057',
    projectId: 'nutriday-a61b5',
    storageBucket: 'nutriday-a61b5.firebasestorage.app',
  );

  static const FirebaseOptions windows = web;
  static const FirebaseOptions macos = web;
  static const FirebaseOptions linux = web;
}

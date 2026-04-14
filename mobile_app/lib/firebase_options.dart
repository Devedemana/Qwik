// Generated from google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKMy5dizkYVFpt5wwUrAFmENH5dTho0XE',
    appId: '1:263806107436:android:6ab25f882eea00b4083689',
    messagingSenderId: '263806107436',
    projectId: 'qwik-c6e20',
    storageBucket: 'qwik-c6e20.firebasestorage.app',
  );
}

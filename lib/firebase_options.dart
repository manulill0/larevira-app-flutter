import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnAh0avlgy1TxLaloZafiPP63lJ7AFcBk',
    appId: '1:1072879556252:android:2a18c8efb2342bd187bf59',
    messagingSenderId: '1072879556252',
    projectId: 'la-revira',
    databaseURL: 'https://la-revira.firebaseio.com',
    storageBucket: 'la-revira.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_IFxz0CgQ6W8wdQ6FVTVjspM2JFM37ZI',
    appId: '1:1072879556252:ios:a12eb6de158ec14087bf59',
    messagingSenderId: '1072879556252',
    projectId: 'la-revira',
    databaseURL: 'https://la-revira.firebaseio.com',
    storageBucket: 'la-revira.firebasestorage.app',
    iosBundleId: 'com.larevira.lareviraAppFlutter',
  );
}

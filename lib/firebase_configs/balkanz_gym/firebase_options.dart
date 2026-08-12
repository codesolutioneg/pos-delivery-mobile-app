// pos-juma — بلكنز الجيم
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      case TargetPlatform.macOS:   return macos;
      case TargetPlatform.windows: return windows;
      case TargetPlatform.linux:   return linux;
      default: throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFOl4OgPVMS56lOJk9gvkX9hI_IcmQh3Y',
    appId: '1:914709343714:web:05f39a4a81ec970c86ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    authDomain: 'pos-juma.firebaseapp.com',
    storageBucket: 'pos-juma.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyaF9spKGMm8akII7Ne2rsDYcwmVTb2h4',
    appId: '1:914709343714:android:4bf0af63243b575686ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    storageBucket: 'pos-juma.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAElhH6V15hTBMzfbwcVGcRHJhourdm8VI',
    appId: '1:914709343714:ios:47ef8f0624a7e0ab86ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    storageBucket: 'pos-juma.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAElhH6V15hTBMzfbwcVGcRHJhourdm8VI',
    appId: '1:914709343714:ios:47ef8f0624a7e0ab86ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    storageBucket: 'pos-juma.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFOl4OgPVMS56lOJk9gvkX9hI_IcmQh3Y',
    appId: '1:914709343714:web:a73e6659e95c29b486ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    authDomain: 'pos-juma.firebaseapp.com',
    storageBucket: 'pos-juma.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCFOl4OgPVMS56lOJk9gvkX9hI_IcmQh3Y',
    appId: '1:914709343714:web:05f39a4a81ec970c86ddbb',
    messagingSenderId: '914709343714',
    projectId: 'pos-juma',
    authDomain: 'pos-juma.firebaseapp.com',
    storageBucket: 'pos-juma.firebasestorage.app',
  );
}

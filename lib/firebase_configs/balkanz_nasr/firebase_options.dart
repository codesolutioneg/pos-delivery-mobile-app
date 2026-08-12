// pos-test-70970 — بلكنز مدينة نصر
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
    apiKey: 'AIzaSyAeOa71QWBwPrrhtLlqfmvhGhVYxkEzEEM',
    appId: '1:197359010308:web:ec55127f4b0a620042ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    authDomain: 'pos-test-70970.firebaseapp.com',
    storageBucket: 'pos-test-70970.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGb6u6rxaQxFqKhtDCyFoltsxMdbRvQSc',
    appId: '1:197359010308:android:c9810feb3337bd4142ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    storageBucket: 'pos-test-70970.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUVJ405CDjZQtPebfU8fdc9WiuEj01QF8',
    appId: '1:197359010308:ios:2b9cc6b3e30f6fad42ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    storageBucket: 'pos-test-70970.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUVJ405CDjZQtPebfU8fdc9WiuEj01QF8',
    appId: '1:197359010308:ios:2b9cc6b3e30f6fad42ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    storageBucket: 'pos-test-70970.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAeOa71QWBwPrrhtLlqfmvhGhVYxkEzEEM',
    appId: '1:197359010308:web:9f7c1b1da4913db942ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    authDomain: 'pos-test-70970.firebaseapp.com',
    storageBucket: 'pos-test-70970.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAeOa71QWBwPrrhtLlqfmvhGhVYxkEzEEM',
    appId: '1:197359010308:web:ec55127f4b0a620042ab51',
    messagingSenderId: '197359010308',
    projectId: 'pos-test-70970',
    authDomain: 'pos-test-70970.firebaseapp.com',
    storageBucket: 'pos-test-70970.firebasestorage.app',
  );
}

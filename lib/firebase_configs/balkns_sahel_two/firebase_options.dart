// balkns-sahel-brunch-tow — Balkanz Sahel فرع اتنين
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
    apiKey: 'AIzaSyCQrjkdgq-923zsU-0SNrkCSX1Ls2l4PKI',
    appId: '1:273561985344:web:f748167bf0ed8c1e951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    authDomain: 'balkns-sahel-brunch-tow.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBj3O5--EdaLAsaLIAz-xsrylFLba0YIpc',
    appId: '1:273561985344:android:7d1fa3a249403767951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTyylmymxS9KSoOoJ3xQtGtgAqZbazPOw',
    appId: '1:273561985344:ios:c0a77b9133031667951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTyylmymxS9KSoOoJ3xQtGtgAqZbazPOw',
    appId: '1:273561985344:ios:c0a77b9133031667951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQrjkdgq-923zsU-0SNrkCSX1Ls2l4PKI',
    appId: '1:273561985344:web:8b1e07388014fb18951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    authDomain: 'balkns-sahel-brunch-tow.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCQrjkdgq-923zsU-0SNrkCSX1Ls2l4PKI',
    appId: '1:273561985344:web:f748167bf0ed8c1e951aa5',
    messagingSenderId: '273561985344',
    projectId: 'balkns-sahel-brunch-tow',
    authDomain: 'balkns-sahel-brunch-tow.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-tow.firebasestorage.app',
  );
}
// balkns-sahel-brunch-one — Balkanz Sahel فرع واحد
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
    apiKey: 'AIzaSyBgRjEFEXSRBLxE9aTZKzGlaiD7x2zXYSA',
    appId: '1:994212390967:web:a7186ef56a55a08b6677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    authDomain: 'balkns-sahel-brunch-one.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAy3vSX526dcgzdZASP44tBcBPEfRuxejs',
    appId: '1:994212390967:android:f450ee3f9116d67c6677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB4FUavCC_rznBH_R2HqkFYvvX3KlsPcEc',
    appId: '1:994212390967:ios:69b2895f795abbc06677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB4FUavCC_rznBH_R2HqkFYvvX3KlsPcEc',
    appId: '1:994212390967:ios:69b2895f795abbc06677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgRjEFEXSRBLxE9aTZKzGlaiD7x2zXYSA',
    appId: '1:994212390967:web:4904b269cb7546bf6677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    authDomain: 'balkns-sahel-brunch-one.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBgRjEFEXSRBLxE9aTZKzGlaiD7x2zXYSA',
    appId: '1:994212390967:web:a7186ef56a55a08b6677b2',
    messagingSenderId: '994212390967',
    projectId: 'balkns-sahel-brunch-one',
    authDomain: 'balkns-sahel-brunch-one.firebaseapp.com',
    storageBucket: 'balkns-sahel-brunch-one.firebasestorage.app',
  );
}
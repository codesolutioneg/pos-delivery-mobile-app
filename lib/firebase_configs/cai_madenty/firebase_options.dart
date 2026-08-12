// pos-admin-dashboard-bf6d9 — كايرو كايز مدينتي
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
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCdbm--N5hCF4Gidec-o32DnHyWXHKQMWw',
    appId: '1:184959799978:web:780fccae27edfc90e9b6d3',
    messagingSenderId: '184959799978',
    projectId: 'pos-admin-dashboard-bf6d9',
    authDomain: 'pos-admin-dashboard-bf6d9.firebaseapp.com',
    storageBucket: 'pos-admin-dashboard-bf6d9.firebasestorage.app',
  );
}

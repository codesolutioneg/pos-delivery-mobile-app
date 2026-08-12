// odc-chat — Dev / Test environment
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
    apiKey: 'AIzaSyC2tKHPj6r_vkPhgVRBNah9zdYvNsjQjn4',
    appId: '1:819111793113:web:32bcc8c12df414002fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    authDomain: 'odc-chat.firebaseapp.com',
    storageBucket: 'odc-chat.appspot.com',
    measurementId: 'G-4R7JG65ZYM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeCLX3DAA5jsYgzVgFfSKAbedKleji3Xc',
    appId: '1:819111793113:android:2775467b9d2484d32fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    storageBucket: 'odc-chat.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFmFEnP-2hFDBNkScaezqdFDRY1IbyH6o',
    appId: '1:819111793113:ios:ceaddcde638c41b22fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    storageBucket: 'odc-chat.appspot.com',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFmFEnP-2hFDBNkScaezqdFDRY1IbyH6o',
    appId: '1:819111793113:ios:ceaddcde638c41b22fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    storageBucket: 'odc-chat.appspot.com',
    iosBundleId: 'com.pos.posSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA5bWhN815R-dsXUSm4XUeaup2y_tEfb0U',
    appId: '1:819111793113:web:fb4b979043a2166f2fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    authDomain: 'odc-chat.firebaseapp.com',
    storageBucket: 'odc-chat.appspot.com',
    measurementId: 'G-MQBN40KRJ9',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyC2tKHPj6r_vkPhgVRBNah9zdYvNsjQjn4',
    appId: '1:819111793113:web:32bcc8c12df414002fc9c8',
    messagingSenderId: '819111793113',
    projectId: 'odc-chat',
    authDomain: 'odc-chat.firebaseapp.com',
    storageBucket: 'odc-chat.appspot.com',
    measurementId: 'G-4R7JG65ZYM',
  );
}

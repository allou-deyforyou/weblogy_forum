// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions, FirebaseApp;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class FirebaseConfig {
  const FirebaseConfig._();

  static FirebaseApp? _app;
  static FirebaseApp get app => _app!;

  static FirebaseAuth get firebaseAuth => FirebaseAuth.instanceFor(app: app);
  static FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instanceFor(app: app);

  static Future<void> development() async {
    _app ??= await Firebase.initializeApp(
      name: 'development',
      options: currentPlatform,
    );
  }

  static Future<void> production() async {
    _app ??= await Firebase.initializeApp(
      options: currentPlatform,
    );
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMAeql7nJdzJE6KSygPsrSgh5q0txnYdw',
    appId: '1:875088066590:android:c98f06328f6c60d07cd60f',
    messagingSenderId: '875088066590',
    projectId: 'weblogy-forum',
    storageBucket: 'weblogy-forum.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCw2cRurtrFNOSpmdfl_DWVpZEVgsHBqLM',
    appId: '1:875088066590:ios:deb4a4117ea130cd7cd60f',
    messagingSenderId: '875088066590',
    projectId: 'weblogy-forum',
    storageBucket: 'weblogy-forum.appspot.com',
    iosClientId: '875088066590-u6pq6sdkvf1k9urp4oaapu60fsrh0alj.apps.googleusercontent.com',
    iosBundleId: 'com.weblogy.forum',
  );
}
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAl6Nw5kFad0prIKeoxIPLqGtYHBd2zPXY',
    appId: '1:270164985236:web:cbb92d4afc5f8b6f56fb81',
    messagingSenderId: '270164985236',
    projectId: 'contact-management-5d438',
    authDomain: 'contact-management-5d438.firebaseapp.com',
    storageBucket: 'contact-management-5d438.appspot.com',
    measurementId: 'G-6W4X10939P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJ50dBbGXasRAFgjC3j285xwaWK7Ctq_o',
    appId: '1:270164985236:android:fd84a488ffa46db256fb81',
    messagingSenderId: '270164985236',
    projectId: 'contact-management-5d438',
    storageBucket: 'contact-management-5d438.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFLBfiuptnmYSc0dZZCJ3Cf99f8Io2rCo',
    appId: '1:270164985236:ios:ce66917c0ca6efff56fb81',
    messagingSenderId: '270164985236',
    projectId: 'contact-management-5d438',
    storageBucket: 'contact-management-5d438.appspot.com',
    iosBundleId: 'com.example.contactManagment',
  );
}

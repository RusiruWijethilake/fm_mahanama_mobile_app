import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fm_mahanama_mobile_app/firebase_options.dart';
import 'package:fm_mahanama_mobile_app/pages/home_page.dart';
import 'package:fm_mahanama_mobile_app/pages/chat_page.dart';
import 'package:fm_mahanama_mobile_app/theme/color_schemes.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo? _packageInfo;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  if (kReleaseMode) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  _packageInfo = await PackageInfo.fromPlatform();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final radioPlayer = AssetsAudioPlayer.withId("fm_mahanama");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FM Mahanama',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      routes: {
        HomePage.routeName: (context) => HomePage(analytics: FirebaseAnalytics.instance, radioPlayer: radioPlayer, packageInfo: _packageInfo!),
        ChatPage.routeName: (context) => ChatPage(analytics: FirebaseAnalytics.instance),
      },
      initialRoute: HomePage.routeName,
    );
  }
}
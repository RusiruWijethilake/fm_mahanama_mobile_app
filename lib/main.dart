import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fm_mahanama_mobile_app/firebase_options.dart';
import 'package:fm_mahanama_mobile_app/pages/home_page.dart';
import 'package:fm_mahanama_mobile_app/theme/color_schemes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
      },
      initialRoute: HomePage.routeName,
    );
  }
}
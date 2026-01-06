import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 1. Mandatory initialization for async main
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 3. Initialize Firebase with a safety catch
  try {
    // We add a timeout of 10 seconds. If it hangs longer, it will throw an error
    // instead of staying on a white screen forever.
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("FIREBASE ERROR: $e");
    // The app will still run, but online features won't work until fixed.
  }

  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
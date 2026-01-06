import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
// 1. IMPORT the new generated options file
import 'firebase_options.dart'; 
import 'screens/splash_screen.dart';

void main() async {
  // 2. Mandatory for async main
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Lock orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 4. Initialize Firebase using the CLI-generated options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully with CLI options");
  } catch (e) {
    debugPrint("FIREBASE INITIALIZATION ERROR: $e");
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
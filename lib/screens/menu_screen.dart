import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';
import '../logic/game_controller.dart';
import '../utils/constants.dart';
import '../widgets/menu_button.dart';
import 'online_lobby.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("TIC TAC TOE", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            MenuButton(
              text: "Local PVP",
              onPressed: () => _launchGame(context, GameMode.pvp),
            ),
            const SizedBox(height: 15),
            MenuButton(
              text: "Easy AI",
              onPressed: () => _launchGame(context, GameMode.easy),
            ),
            const SizedBox(height: 15),
            MenuButton(
              text: "Impossible AI",
              onPressed: () => _launchGame(context, GameMode.impossible),
            ),
            const SizedBox(height: 15),
            MenuButton(
              text: "Exit",
              onPressed: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _launchGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(mode: mode)),
    );
  }
}
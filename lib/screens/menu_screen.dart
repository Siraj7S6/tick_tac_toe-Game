import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

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
            Text(
              "Ultimate\nTic Tac Toe",
              textAlign: TextAlign.center,
              style: GoogleFonts.russoOne(fontSize: 48, color: Colors.white),
            ),
            const SizedBox(height: 60),
            _menuButton(context, "PLAY OFFLINE", Icons.play_arrow, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
            }),
            const SizedBox(height: 20),
            _menuButton(context, "EXIT", Icons.exit_to_app, () {
              // Note: SystemNavigator.pop() or similar for actual exit
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryBg,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
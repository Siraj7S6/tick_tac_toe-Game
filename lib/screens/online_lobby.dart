import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'online_game_screen.dart';

class OnlineLobby extends StatefulWidget {
  const OnlineLobby({super.key});

  @override
  State<OnlineLobby> createState() => _OnlineLobbyState();
}

class _OnlineLobbyState extends State<OnlineLobby> {
  final TextEditingController _codeController = TextEditingController();

  // Generates a 6-digit code and creates a room in Firebase
  void _createRoom() {
    String code = (Random().nextInt(899999) + 100000).toString();

    FirebaseDatabase.instance.ref("rooms/$code").set({
      'board': List.filled(9, ""),
      'isXTurn': true,
      'winner': null,
      'winningLine': null,
      'createdAt': ServerValue.timestamp,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnlineGameScreen(roomCode: code, mySymbol: "X"),
      ),
    );
  }

  void _joinRoom() {
    String code = _codeController.text.trim();
    if (code.length == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnlineGameScreen(roomCode: code, mySymbol: "O"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ONLINE PLAY", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),

            // Create Room Button
            _lobbyButton("CREATE ROOM", _createRoom, Colors.greenAccent),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text("OR", style: TextStyle(color: Colors.white54)),
            ),

            // Join Room Section
            Container(
              width: 250,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  hintText: "Enter 6-digit code",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _lobbyButton("JOIN ROOM", _joinRoom, AppColors.accentBg),
          ],
        ),
      ),
    );
  }

  Widget _lobbyButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
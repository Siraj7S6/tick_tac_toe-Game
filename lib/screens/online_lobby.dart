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
  bool _isCreating = false;

  // 1. FORCED DATABASE REFERENCE (Fixes the "Null" Database URL issue on Web)
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://ticktacktoe-282aa-default-rtdb.firebaseio.com/',
  ).ref("rooms");

  // Logic to Create a Room
  void _createRoom() async {
    setState(() => _isCreating = true);
    String code = (Random().nextInt(899999) + 100000).toString();

    try {
      // 2. Initializing Room Data
      await _dbRef.child(code).set({
        'board': List.filled(9, ""),
        'isXTurn': true,
        'winner': null,
        'player1Joined': true,
        'player2Joined': false, // This will be the trigger for the host
        'createdAt': ServerValue.timestamp,
      });

      // 3. START LISTENING: The Host waits for Player 2 to join
      _listenForOpponent(code);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.primaryBg,
          title: const Text("Room Created!", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Share this code with your friend:", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Text(code, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text("Waiting for opponent...", style: TextStyle(fontSize: 14, color: Colors.white38)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            )
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error creating room: $e");
      setState(() => _isCreating = false);
    }
  }

  // 4. LISTENER: Tells the Host when the Opponent joins
  void _listenForOpponent(String code) {
    _dbRef.child(code).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map;
        if (data['player2Joined'] == true) {
          // If Player 2 joins, close the dialog and start the game
          if (Navigator.canPop(context)) Navigator.pop(context);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OnlineGameScreen(roomCode: code, mySymbol: "X"),
            ),
          );
        }
      }
    });
  }

  // Logic to Join a Room
  void _joinRoom() async {
    String code = _codeController.text.trim();
    if (code.length != 6) return;

    final snapshot = await _dbRef.child(code).get();
    if (snapshot.exists) {
      // 5. UPDATE: Inform the database that Player 2 has entered
      await _dbRef.child(code).update({'player2Joined': true});

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnlineGameScreen(roomCode: code, mySymbol: "O"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room not found! Check the code.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(title: const Text("Online Lobby"), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _lobbyButton(_isCreating ? "CREATING..." : "CREATE ROOM", _createRoom, Colors.blue),
            const SizedBox(height: 30),
            const Text("OR", style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 30),
            Container(
              width: 250,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Enter 6-digit code", border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 20),
            _lobbyButton("JOIN ROOM", _joinRoom, Colors.green),
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
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
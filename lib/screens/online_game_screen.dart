import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/online_controller.dart';
import '../widgets/game_cell.dart';
import '../utils/constants.dart';

class OnlineGameScreen extends StatefulWidget {
  final String roomCode;
  final String mySymbol; // "X" or "O"

  const OnlineGameScreen({super.key, required this.roomCode, required this.mySymbol});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late OnlineController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the online controller with room code and symbol
    _controller = OnlineController(roomCode: widget.roomCode, mySymbol: widget.mySymbol);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: ValueListenableBuilder<OnlineState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              // 1. DYNAMIC TURN CALCULATION
              // Updates automatically when the controller resets the isXTurn flag
              bool isMyTurn = (state.isXTurn && widget.mySymbol == "X") ||
                  (!state.isXTurn && widget.mySymbol == "O");

              return Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Text(
                    // Only show turn info if the game is still active
                    state.winner == null 
                      ? (isMyTurn ? "YOUR TURN (${widget.mySymbol})" : "WAITING FOR OPPONENT...")
                      : "GAME OVER",
                    style: GoogleFonts.poppins(
                        color: isMyTurn ? Colors.greenAccent : Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  _buildGrid(state, isMyTurn),
                  const Spacer(),
                  // 2. UPDATED RESULT UI
                  if (state.winner != null) _buildResult(state.winner!),
                  const SizedBox(height: 50),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "ROOM: ${widget.roomCode}",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(OnlineState state, bool isMyTurn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: 9,
          itemBuilder: (context, index) => GameCell(
            value: state.board[index],
            // Only allow taps if it's the player's turn and game isn't over
            onTap: (isMyTurn && state.winner == null) 
                ? () => _controller.makeMove(index) 
                : () {},
          ),
        ),
      ),
    );
  }

  Widget _buildResult(String winner) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white10, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24)
      ),
      child: Column(
        children: [
          Text(
            winner == "Draw" ? "IT'S A DRAW!" : "PLAYER $winner WINS!",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3. PLAY AGAIN BUTTON
              // This calls the resetGame function we added to the controller
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _controller.resetGame(),
                child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              // EXIT BUTTON
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("EXIT", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
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
              bool isMyTurn = (state.isXTurn && widget.mySymbol == "X") ||
                  (!state.isXTurn && widget.mySymbol == "O");

              return Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Text(
                    isMyTurn ? "YOUR TURN (${widget.mySymbol})" : "WAITING FOR OPPONENT...",
                    style: GoogleFonts.poppins(
                        color: isMyTurn ? Colors.greenAccent : Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  _buildGrid(state),
                  const Spacer(),
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

  Widget _buildGrid(OnlineState state) {
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
            onTap: () => _controller.makeMove(index),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(String winner) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Text(
        winner == "Draw" ? "IT'S A DRAW!" : "PLAYER $winner WINS!",
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
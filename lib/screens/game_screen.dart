import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../logic/game_controller.dart';
import '../utils/constants.dart';
import '../widgets/game_cell.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _controller = GameController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_gameListener);
  }

  void _gameListener() {
    final state = _controller.value;

    // --- SOUND LOGIC ---
    // Triggers based on the lastEvent updated in the Controller
    if (state.lastEvent == GameEvent.move) {
      _audioPlayer.play(AssetSource('sounds/Move.mp3'));
    } else if (state.lastEvent == GameEvent.win) {
      _audioPlayer.play(AssetSource('sounds/WinGame.mp3'));
      _showResultDialog(state.winner);
    } else if (state.lastEvent == GameEvent.draw) {
      _audioPlayer.play(AssetSource('sounds/DrawGame.mp3'));
      _showResultDialog(null);
    }
  }

  void _showResultDialog(String? winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          winner == null ? "It's a Draw!" : "Player $winner Wins!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                _controller.resetMatch();
                Navigator.pop(context);
              },
              child: Text(
                "Play Again",
                style: GoogleFonts.poppins(
                  color: AppColors.accentBg,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_gameListener);
    _controller.dispose();
    _audioPlayer.dispose(); // Clean up audio resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<GameState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return Container(
            decoration: const BoxDecoration(gradient: AppColors.mainGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Calculates height minus the top safe area padding
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Top Navigation Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                                onPressed: () => _controller.resetScores(),
                              ),
                            ],
                          ),
                        ),

                        // Score Board Section
                        ScoreBoard(
                          scoreX: state.scoreX,
                          scoreO: state.scoreO,
                          isXTurn: state.isXTurn,
                        ),

                        const Spacer(),

                        // Game Grid Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                bool isWinning = state.winningLine?.contains(index) ?? false;
                                return GameCell(
                                  value: state.board[index],
                                  isWinningCell: isWinning,
                                  onTap: () => _controller.makeMove(index),
                                );
                              },
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Turn Indicator Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.isXTurn ? "Player X's Turn" : "Player O's Turn",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: state.isXTurn ? AppColors.playerXColor : AppColors.playerOColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../logic/game_controller.dart';
import '../utils/constants.dart';
import '../widgets/game_cell.dart';
import '../widgets/score_board.dart';
import '../widgets/winning_line_painter.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// FIXED: Added SingleTickerProviderStateMixin to provide the 'vsync' for animations
class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final GameController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  // Animation variables for the winning line
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = GameController(mode: widget.mode);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Initialize the line animation controller
    _lineAnimationController = AnimationController(
      vsync: this, // This now works because of the mixin above
      duration: const Duration(milliseconds: 600),
    );

    _lineAnimation = CurvedAnimation(
      parent: _lineAnimationController,
      curve: Curves.easeInOut,
    );

    _controller.addListener(_gameListener);
  }

  void _gameListener() {
    final state = _controller.value;

    if (state.lastEvent == GameEvent.move) {
      HapticFeedback.lightImpact();
      _audioPlayer.play(AssetSource('sounds/Move.mp3'));
    }
    else if (state.lastEvent == GameEvent.win) {
      HapticFeedback.vibrate();
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/WinGame.mp3'));

      // Start the animated line drawing
      _lineAnimationController.forward(from: 0.0);

      _showResultDialog(state.winner);
    }
    else if (state.lastEvent == GameEvent.draw) {
      HapticFeedback.mediumImpact();
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
                _lineAnimationController.reset(); // Clear the line for next round
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
    _audioPlayer.dispose();
    _confettiController.dispose();
    _lineAnimationController.dispose(); // Clean up animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<GameState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              return Container(
                decoration: const BoxDecoration(gradient: AppColors.mainGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      ScoreBoard(
                        scoreX: state.scoreX,
                        scoreO: state.scoreO,
                        isXTurn: state.isXTurn,
                      ),
                      const Spacer(),
                      _buildGrid(state),
                      const Spacer(),
                      _buildTurnIndicator(state),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.mode == GameMode.pvp ? "LOCAL PVP" :
            widget.mode == GameMode.easy ? "EASY AI" : "IMPOSSIBLE",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: () {
              _controller.resetScores();
              _lineAnimationController.reset();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => GameCell(
                value: state.board[index],
                isWinningCell: false, // We use the painter line now instead
                onTap: () => _controller.makeMove(index),
              ),
            ),

            // The Winning Line Layer
            if (state.winner != null && state.winningLine != null)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: WinningLinePainter(
                        winningLine: state.winningLine!,
                        progress: _lineAnimation.value,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        state.isXTurn ? "Your Turn (X)" : "Opponent (O)",
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
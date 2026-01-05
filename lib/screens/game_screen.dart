import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../logic/game_controller.dart';
import '../utils/constants.dart';
import '../widgets/game_cell.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = GameController(mode: widget.mode);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _controller.addListener(_gameListener);
  }

  void _gameListener() {
    final state = _controller.value;
    if (state.lastEvent == GameEvent.move) {
      HapticFeedback.lightImpact();
      _audioPlayer.play(AssetSource('sounds/Move.mp3'));
    } else if (state.lastEvent == GameEvent.win) {
      HapticFeedback.vibrate();
      _confettiController.play();
      _audioPlayer.play(AssetSource('sounds/WinGame.mp3'));
      _showResultDialog(state.winner);
    } else if (state.lastEvent == GameEvent.draw) {
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
        title: Text(winner == null ? "Draw!" : "Player $winner Wins!",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actions: [Center(child: TextButton(onPressed: () {
          _controller.resetMatch();
          Navigator.pop(context);
        }, child: const Text("Play Again")))],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_gameListener);
    _controller.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        ScoreBoard(scoreX: state.scoreX, scoreO: state.scoreO, isXTurn: state.isXTurn),
                        const SizedBox(height: 40),
                        _buildGrid(state),
                        const SizedBox(height: 40),
                        _buildTurnIndicator(state),
                      ],
                    ),
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
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Text(widget.mode == GameMode.pvp ? "Local PVP" : widget.mode == GameMode.easy ? "Easy AI" : "Impossible AI",
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _controller.resetScores()),
        ],
      ),
    );
  }

  Widget _buildGrid(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: 9,
          itemBuilder: (context, index) => GameCell(
            value: state.board[index],
            isWinningCell: state.winningLine?.contains(index) ?? false,
            onTap: () => _controller.makeMove(index),
          ),
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
      child: Text(state.isXTurn ? "Your Turn (X)" : "Opponent (O)",
          style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
  }
}
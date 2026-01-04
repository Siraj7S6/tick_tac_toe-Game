import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ScoreBoard extends StatelessWidget {
  final int scoreX;
  final int scoreO;
  final bool isXTurn;

  const ScoreBoard({
    super.key,
    required this.scoreX,
    required this.scoreO,
    required this.isXTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreColumn("Player X", scoreX, AppColors.playerXColor, isXTurn),
        _buildScoreColumn("Player O", scoreO, AppColors.playerOColor, !isXTurn),
      ],
    );
  }

  Widget _buildScoreColumn(String title, int score, Color color, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: isActive ? color : Colors.white70,
            fontSize: 18,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : Colors.white12),
          ),
          child: Text(
            score.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
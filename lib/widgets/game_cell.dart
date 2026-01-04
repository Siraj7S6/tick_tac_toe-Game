import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class GameCell extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isWinningCell;

  const GameCell({
    super.key,
    required this.value,
    required this.onTap,
    this.isWinningCell = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isWinningCell ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          border: Border.all(
            color: isWinningCell ? Colors.white : Colors.white24,
            width: isWinningCell ? 3 : 1,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: value == "X" ? AppColors.playerXColor : AppColors.playerOColor,
            ),
          ),
        ),
      ),
    );
  }
}
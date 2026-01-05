import 'dart:ui';
import 'package:flutter/material.dart';

class WinningLinePainter extends CustomPainter {
  final List<int> winningLine;
  final double progress; // 0.0 to 1.0 for animation
  final Color color;

  WinningLinePainter({
    required this.winningLine,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.length < 3) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Calculate coordinates for the 3x3 grid
    double cellSize = size.width / 3;

    Offset getOffset(int index) {
      int row = index ~/ 3;
      int col = index % 3;
      return Offset(
        (col * cellSize) + (cellSize / 2),
        (row * cellSize) + (cellSize / 2),
      );
    }

    Offset start = getOffset(winningLine.first);
    Offset end = getOffset(winningLine.last);

    // Animate the line drawing from start to end based on progress
    Offset currentEnd = Offset(
      lerpDouble(start.dx, end.dx, progress)!,
      lerpDouble(start.dy, end.dy, progress)!,
    );

    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.winningLine != winningLine;
  }
}
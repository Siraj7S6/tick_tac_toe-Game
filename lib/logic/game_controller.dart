import 'dart:math';
import 'package:flutter/material.dart';

enum GameEvent { none, move, win, draw }
enum GameMode { pvp, easy, impossible }

class GameController extends ValueNotifier<GameState> {
  // FIXED: Constructor now correctly accepts 'mode'
  GameController({GameMode mode = GameMode.pvp}) : super(GameState.initial(mode));

  void makeMove(int index) {
    if (value.board[index] != "" || value.winner != null) return;

    _processMove(index);

    // Trigger AI move if it's not PVP and game isn't over
    if (value.mode != GameMode.pvp && value.winner == null && !value.isDraw && !value.isXTurn) {
      Future.delayed(const Duration(milliseconds: 600), () => _aiMove());
    }
  }

  void _aiMove() {
    int move = value.mode == GameMode.easy ? _getRandomMove() : _getBestMove();
    _processMove(move);
  }

  void _processMove(int index) {
    List<String> newBoard = List.from(value.board);
    newBoard[index] = value.isXTurn ? "X" : "O";

    String? winner = _checkWinner(newBoard);
    List<int>? winningLine = _getWinningLine(newBoard);
    bool isDraw = !newBoard.contains("") && winner == null;

    int newScoreX = value.scoreX;
    int newScoreO = value.scoreO;

    GameEvent event = GameEvent.move;
    if (winner != null) {
      event = GameEvent.win;
      winner == "X" ? newScoreX++ : newScoreO++;
    } else if (isDraw) {
      event = GameEvent.draw;
    }

    value = value.copyWith(
      board: newBoard,
      isXTurn: !value.isXTurn,
      winner: winner,
      winningLine: winningLine,
      isDraw: isDraw,
      scoreX: newScoreX,
      scoreO: newScoreO,
      lastEvent: event,
    );
  }

  int _getRandomMove() {
    List<int> available = [];
    for (int i = 0; i < 9; i++) {
      if (value.board[i] == "") available.add(i);
    }
    return available[Random().nextInt(available.length)];
  }

  int _getBestMove() {
    int bestScore = -1000;
    int move = -1;
    for (int i = 0; i < 9; i++) {
      if (value.board[i] == "") {
        value.board[i] = "O";
        int score = _minimax(value.board, 0, false);
        value.board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String? result = _checkWinner(board);
    if (result == "O") return 10 - depth;
    if (result == "X") return depth - 10;
    if (!board.contains("")) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = _minimax(board, depth + 1, false);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "X";
          int score = _minimax(board, depth + 1, true);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String? _checkWinner(List<String> b) {
    List<List<int>> lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var line in lines) {
      if (b[line[0]] != "" && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) return b[line[0]];
    }
    return null;
  }

  List<int>? _getWinningLine(List<String> b) {
    List<List<int>> lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var line in lines) {
      if (b[line[0]] != "" && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) return line;
    }
    return null;
  }

  void resetMatch() => value = value.copyWith(
      board: List.filled(9, ""), isXTurn: true, winner: null, winningLine: [], isDraw: false, lastEvent: GameEvent.none);

  void resetScores() => value = GameState.initial(value.mode);
}

class GameState {
  final List<String> board;
  final bool isXTurn;
  final String? winner;
  final List<int>? winningLine;
  final bool isDraw;
  final int scoreX;
  final int scoreO;
  final GameEvent lastEvent;
  final GameMode mode;

  GameState({
    required this.board, required this.isXTurn, this.winner, this.winningLine,
    required this.isDraw, required this.scoreX, required this.scoreO,
    this.lastEvent = GameEvent.none, required this.mode,
  });

  factory GameState.initial(GameMode mode) => GameState(
      board: List.filled(9, ""), isXTurn: true, isDraw: false, scoreX: 0, scoreO: 0,
      winningLine: [], lastEvent: GameEvent.none, mode: mode);

  GameState copyWith({
    List<String>? board, bool? isXTurn, String? winner, List<int>? winningLine,
    bool? isDraw, int? scoreX, int? scoreO, GameEvent? lastEvent, GameMode? mode,
  }) {
    return GameState(
      board: board ?? this.board, isXTurn: isXTurn ?? this.isXTurn, winner: winner,
      winningLine: winningLine ?? this.winningLine, isDraw: isDraw ?? this.isDraw,
      scoreX: scoreX ?? this.scoreX, scoreO: scoreO ?? this.scoreO,
      lastEvent: lastEvent ?? GameEvent.none, mode: mode ?? this.mode,
    );
  }
}
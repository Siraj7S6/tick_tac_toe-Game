import 'package:flutter/material.dart';

/// Defines the types of audio-visual events that can occur during a game
/// These correspond to your specific sound files: Move, WinGame, and DrawGame.
enum GameEvent { none, move, win, draw }

class GameController extends ValueNotifier<GameState> {
  GameController() : super(GameState.initial());

  void makeMove(int index) {
    // 1. Prevent moves on occupied cells or if the game is already over
    if (value.board[index] != "" || value.winner != null) return;

    // 2. Create a copy of the current board and update the cell
    List<String> newBoard = List.from(value.board);
    newBoard[index] = value.isXTurn ? "X" : "O";

    // 3. Check for game results
    String? winner = _checkWinner(newBoard);
    List<int>? winningLine = _getWinningLine(newBoard);
    bool isDraw = !newBoard.contains("") && winner == null;

    int newScoreX = value.scoreX;
    int newScoreO = value.scoreO;

    // 4. Determine which sound/event to trigger for the UI
    GameEvent event = GameEvent.move;

    if (winner != null) {
      event = GameEvent.win;
      if (winner == "X") newScoreX++;
      if (winner == "O") newScoreO++;
    } else if (isDraw) {
      event = GameEvent.draw;
    }

    // 5. Update the state with the new values and the specific event
    value = value.copyWith(
      board: newBoard,
      isXTurn: !value.isXTurn,
      winner: winner,
      winningLine: winningLine,
      isDraw: isDraw,
      scoreX: newScoreX,
      scoreO: newScoreO,
      lastEvent: event, // This notifies the UI to play the sound
    );
  }

  void resetMatch() {
    value = value.copyWith(
      board: List.filled(9, ""),
      isXTurn: true,
      winner: null,
      winningLine: [],
      isDraw: false,
      lastEvent: GameEvent.none,
    );
  }

  void resetScores() {
    value = GameState.initial();
  }

  String? _checkWinner(List<String> b) {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];
    for (var line in lines) {
      if (b[line[0]] != "" && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) {
        return b[line[0]];
      }
    }
    return null;
  }

  List<int>? _getWinningLine(List<String> b) {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var line in lines) {
      if (b[line[0]] != "" && b[line[0]] == b[line[1]] && b[line[0]] == b[line[2]]) {
        return line;
      }
    }
    return null;
  }
}

class GameState {
  final List<String> board;
  final bool isXTurn;
  final String? winner;
  final List<int>? winningLine;
  final bool isDraw;
  final int scoreX;
  final int scoreO;
  final GameEvent lastEvent; // Field used to trigger sounds in the UI

  GameState({
    required this.board,
    required this.isXTurn,
    this.winner,
    this.winningLine,
    required this.isDraw,
    required this.scoreX,
    required this.scoreO,
    this.lastEvent = GameEvent.none,
  });

  factory GameState.initial() => GameState(
    board: List.filled(9, ""),
    isXTurn: true,
    isDraw: false,
    scoreX: 0,
    scoreO: 0,
    winningLine: [],
    lastEvent: GameEvent.none,
  );

  GameState copyWith({
    List<String>? board,
    bool? isXTurn,
    String? winner,
    List<int>? winningLine,
    bool? isDraw,
    int? scoreX,
    int? scoreO,
    GameEvent? lastEvent,
  }) {
    return GameState(
      board: board ?? this.board,
      isXTurn: isXTurn ?? this.isXTurn,
      winner: winner,
      winningLine: winningLine ?? this.winningLine,
      isDraw: isDraw ?? this.isDraw,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
      lastEvent: lastEvent ?? GameEvent.none,
    );
  }
}
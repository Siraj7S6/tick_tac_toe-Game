import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineController extends ValueNotifier<OnlineState> {
  final String roomCode;
  final String mySymbol; // "X" for the host, "O" for the joiner
  final DatabaseReference _dbRef;

  OnlineController({required this.roomCode, required this.mySymbol})
      : // ADDED: Explicit URL for Web support
        _dbRef = FirebaseDatabase.instanceFor(
          app: FirebaseDatabase.instance.app,
          databaseURL: 'https://ticktacktoe-282aa-default-rtdb.firebaseio.com/',
        ).ref("rooms/$roomCode"),
        super(OnlineState.initial()) {
    _initRoomListener();
  }

  void resetGame() async {
  try {
    // Resetting the room data to its initial state
    await _dbRef.update({
      'board': List.filled(9, ""),
      'isXTurn': true,
      'winner': null,
      'winningLine': null,
    });
  } catch (e) {
    debugPrint("RESET ERROR: $e");
  }
}

  // This function "listens" to the internet.
  // If the other player moves, your screen updates automatically.
  void _initRoomListener() {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      // Improved Map parsing for web stability
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      value = OnlineState(
        board: List<String>.from(data['board']),
        isXTurn: data['isXTurn'] ?? true,
        winner: data['winner'],
        winningLine: data['winningLine'] != null
            ? List<int>.from(data['winningLine'])
            : null,
      );
    });
  }

  void makeMove(int index) async {
    // 1. Check if it's actually your turn
    bool isMyTurn = (value.isXTurn && mySymbol == "X") || (!value.isXTurn && mySymbol == "O");

    // 2. Prevent move if wrong turn, cell taken, or game over
    if (!isMyTurn || value.board[index] != "" || value.winner != null) return;

    List<String> newBoard = List.from(value.board);
    newBoard[index] = mySymbol;

    // Calculate if this move won the game
    String? winner = _calculateWinner(newBoard);
    List<int>? line = _getWinningLine(newBoard);
    
    // Check for a Draw (if board is full and no winner)
    if (winner == null && !newBoard.contains("")) {
      winner = "Draw";
    }

    try {
      // 3. Push the update to the Cloud
      await _dbRef.update({
        'board': newBoard,
        'isXTurn': !value.isXTurn,
        'winner': winner,
        'winningLine': line,
      });
    } catch (e) {
      debugPrint("MOVE ERROR: $e");
    }
  }

  String? _calculateWinner(List<String> b) {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var l in lines) {
      if (b[l[0]] != "" && b[l[0]] == b[l[1]] && b[l[0]] == b[l[2]]) return b[l[0]];
    }
    return null;
  }

  List<int>? _getWinningLine(List<String> b) {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var l in lines) {
      if (b[l[0]] != "" && b[l[0]] == b[l[1]] && b[l[0]] == b[l[2]]) return l;
    }
    return null;
  }
}

class OnlineState {
  final List<String> board;
  final bool isXTurn;
  final String? winner;
  final List<int>? winningLine;

  OnlineState({required this.board, required this.isXTurn, this.winner, this.winningLine});

  factory OnlineState.initial() => OnlineState(board: List.filled(9, ""), isXTurn: true);
}
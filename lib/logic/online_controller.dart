import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 

class OnlineController extends ValueNotifier<OnlineState> {
  final String roomCode;
  final String mySymbol; 
  final DatabaseReference _dbRef;
  
  // Audio Player Instance for sound effects
  final AudioPlayer _audioPlayer = AudioPlayer();

  OnlineController({required this.roomCode, required this.mySymbol})
      : _dbRef = FirebaseDatabase.instanceFor(
          app: FirebaseDatabase.instance.app,
          databaseURL: 'https://ticktacktoe-282aa-default-rtdb.firebaseio.com/',
        ).ref("rooms/$roomCode"),
        super(OnlineState.initial()) {
    _initRoomListener();
  }

  // Helper function to play the specific sounds you requested
  void _playSound(String fileName) async {
    try {
      await _audioPlayer.stop(); 
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void resetGame() async {
    try {
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

  void _initRoomListener() {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      List<String> newBoard = List<String>.from(data['board']);
      String? serverWinner = data['winner'];

      // 1. Play Move.mp3 if the board changed
      if (newBoard.join() != value.board.join()) {
        _playSound('Move.mp3');
      }

      // 2. Play WinGame.mp3 or DrawGame.mp3 when the game ends
      if (serverWinner != null && value.winner == null) {
        if (serverWinner == "Draw") {
          _playSound('DrawGame.mp3');
        } else {
          _playSound('WinGame.mp3');
        }
      }

      value = OnlineState(
        board: newBoard,
        isXTurn: data['isXTurn'] ?? true,
        winner: serverWinner,
        winningLine: data['winningLine'] != null
            ? List<int>.from(data['winningLine'])
            : null,
      );
    });
  }

  void makeMove(int index) async {
    bool isMyTurn = (value.isXTurn && mySymbol == "X") || (!value.isXTurn && mySymbol == "O");

    if (!isMyTurn || value.board[index] != "" || value.winner != null) return;

    List<String> newBoard = List.from(value.board);
    newBoard[index] = mySymbol;

    String? winner = _calculateWinner(newBoard);
    List<int>? line = _getWinningLine(newBoard);
    
    if (winner == null && !newBoard.contains("")) {
      winner = "Draw";
    }

    try {
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

  @override
  void dispose() {
    _audioPlayer.dispose(); 
    super.dispose();
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

// THIS WAS LIKELY MISSING: The State class definition
class OnlineState {
  final List<String> board;
  final bool isXTurn;
  final String? winner;
  final List<int>? winningLine;

  OnlineState({
    required this.board, 
    required this.isXTurn, 
    this.winner, 
    this.winningLine
  });

  factory OnlineState.initial() => OnlineState(
    board: List.filled(9, ""), 
    isXTurn: true
  );
}
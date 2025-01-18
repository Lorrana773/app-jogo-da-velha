import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const JogoDaVelhaApp());
}

class JogoDaVelhaApp extends StatelessWidget {
  const JogoDaVelhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jogo da Velha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const JogoDaVelha(),
    );
  }
}

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> board = List.filled(9, '');
  bool xTurn = true;
  String winner = '';
  bool isSinglePlayer = true;

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      xTurn = true;
      winner = '';
    });
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && winner.isEmpty) {
      setState(() {
        board[index] = xTurn ? 'X' : 'O';
        xTurn = !xTurn;
        winner = _checkWinner();
      });

      if (isSinglePlayer && !xTurn && winner.isEmpty) {
        _makeAIMove();
      }
    }
  }

  void _makeAIMove() {
    List<int> emptyIndexes = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        emptyIndexes.add(i);
      }
    }

    if (emptyIndexes.isEmpty) return;

    int? bestMove = _findBestMove('O') ?? _findBestMove('X');
    int aiMove = bestMove ?? emptyIndexes[Random().nextInt(emptyIndexes.length)];

    setState(() {
      board[aiMove] = 'O';
      xTurn = true;
      winner = _checkWinner();
    });
  }

  int? _findBestMove(String player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        if (_checkWinner() == player) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }
    return null;
  }

  String _checkWinner() {
    const winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      final a = condition[0];
      final b = condition[1];
      final c = condition[2];

      if (board[a].isNotEmpty && board[a] == board[b] && board[a] == board[c]) {
        return board[a];
      }
    }

    if (board.every((element) => element.isNotEmpty)) {
      return 'Empate';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Velha'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double boardSize = constraints.maxWidth < 500
              ? constraints.maxWidth * 0.9
              : 400; // Ajuste dinâmico para telas pequenas.

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Modo de jogo:'),
                        Switch(
                          value: isSinglePlayer,
                          onChanged: (value) {
                            setState(() {
                              isSinglePlayer = value;
                              _resetGame();
                            });
                          },
                        ),
                        Text(isSinglePlayer ? 'Máquina' : 'Humano'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _makeMove(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[100],
                                border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  board[index],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (winner.isNotEmpty)
                      Text(
                        winner == 'Empate' ? 'Empate!' : 'Vencedor: $winner',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text('Reiniciar Jogo'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
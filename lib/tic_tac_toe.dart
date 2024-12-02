import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Matte black background
        primarySwatch: Colors.blue,
      ),
      home: const GameModeSelectionScreen(),
    );
  }
}

class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game Mode'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TicTacToeScreen(isAI: true)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.deepPurple,
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Play vs AI'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TicTacToeScreen(isAI: false)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.deepPurple,
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Play vs Friend'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  final bool isAI;

  const TicTacToeScreen({Key? key, required this.isAI}) : super(key: key);

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool isGameOver = false;

  void resetBoard() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      isGameOver = false;
    });
  }

  void _makeMove(int index) {
    if (board[index] == '' && !isGameOver) {
      setState(() {
        board[index] = currentPlayer;
        if (_checkWinner()) {
          winner = '$currentPlayer Wins!';
          isGameOver = true;
        } else if (!_boardHasEmptySpaces()) {
          winner = 'It\'s a Draw!';
          isGameOver = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
      if (!isGameOver && widget.isAI && currentPlayer == 'O') {
        aiMove();
      }
    }
  }

  void aiMove() {
    int bestMove = _findBestMove();
    setState(() {
      board[bestMove] = 'O';
      currentPlayer = 'X';
      if (_checkWinner()) {
        winner = 'AI Wins!';
        isGameOver = true;
      } else if (!_boardHasEmptySpaces()) {
        winner = 'It\'s a Draw!';
        isGameOver = true;
      }
    });
  }

  int _findBestMove() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '')
        return i; // Simplified for now; use Minimax for better AI.
    }
    return -1;
  }

  bool _checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] != '') {
        return true;
      }
    }
    return false;
  }

  bool _boardHasEmptySpaces() => board.contains('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              winner.isNotEmpty ? winner : 'Player $currentPlayer\'s turn',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _makeMove(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(
                            fontSize: 64,
                            color:
                                board[index] == 'X' ? Colors.blue : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (isGameOver)
              ElevatedButton(
                onPressed: resetBoard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Play Again'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'snake_game.dart';
import 'tic_tac_toe.dart';
import 'tetris.dart';

void main() => runApp(const GameBoxApp());

class GameBoxApp extends StatelessWidget {
  const GameBoxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameBox',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const GameBoxHome(),
    );
  }
}

class GameBoxHome extends StatelessWidget {
  const GameBoxHome({Key? key}) : super(key: key);

  // Function to show Tic Tac Toe options
  void _showTicTacToeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TicTacToeScreen(isAI: true),
                    ),
                  );
                },
                child: const Text('Play vs AI'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TicTacToeScreen(isAI: false),
                    ),
                  );
                },
                child: const Text('Play vs Friend'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameBox'),
        centerTitle: true,
      ),
      body: Center(
        // Center the content on the screen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Ensures the children are centered
          children: [
            const Text(
              'Welcome to GameBox!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SnakeGameScreen()),
              ),
              child: const Text('Snake'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showTicTacToeOptions(
                  context), // Show options for Tic Tac Toe
              child: const Text('Tic Tac Toe'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TetrisGame()),
              ),
              child: const Text('Tetris'),
            ),
            const SizedBox(height: 20),
            const Text(
              'More Games Coming Soon...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            const Text(
              'Developed By: Shaikat-CSE',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

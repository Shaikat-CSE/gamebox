import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(TetrisApp());

class TetrisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris',
      debugShowCheckedModeBanner: false,
      home: TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  @override
  _TetrisGameState createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rows = 20;
  static const int columns = 10;

  static const List<List<List<int>>> shapes = [
    [
      [1, 1, 1],
      [0, 1, 0]
    ], // T shape
    [
      [1, 1, 0],
      [0, 1, 1]
    ], // Z shape
    [
      [0, 1, 1],
      [1, 1, 0]
    ], // S shape
    [
      [1, 1],
      [1, 1]
    ], // Square shape
    [
      [1, 1, 1, 1]
    ], // Line shape
  ];

  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  List<List<int>> grid = List.generate(rows, (_) => List.filled(columns, 0));
  List<List<int>>? currentShape;
  int currentColorIndex = 0;
  int currentRow = 0;
  int currentCol = 0;
  int score = 0;
  Timer? gameLoopTimer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    spawnBlock();
    gameLoopTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        moveBlockDown();
      });
    });
  }

  void spawnBlock() {
    currentShape = shapes[random.nextInt(shapes.length)];
    currentColorIndex = random.nextInt(colors.length);
    currentRow = 0;
    currentCol = columns ~/ 2 - (currentShape![0].length ~/ 2);

    if (!canPlace(currentShape!, currentRow, currentCol)) {
      gameLoopTimer?.cancel();
      showGameOverDialog();
    }
  }

  bool canPlace(List<List<int>> shape, int row, int col) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          int newRow = row + i;
          int newCol = col + j;
          if (newRow >= rows ||
              newCol < 0 ||
              newCol >= columns ||
              (newRow >= 0 && grid[newRow][newCol] > 0)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placeShape() {
    for (int i = 0; i < currentShape!.length; i++) {
      for (int j = 0; j < currentShape![i].length; j++) {
        if (currentShape![i][j] == 1) {
          grid[currentRow + i][currentCol + j] = currentColorIndex + 1;
        }
      }
    }
  }

  void moveBlockDown() {
    if (canPlace(currentShape!, currentRow + 1, currentCol)) {
      currentRow++;
    } else {
      placeShape();
      clearRows();
      spawnBlock();
    }
  }

  void quickDrop() {
    while (canPlace(currentShape!, currentRow + 1, currentCol)) {
      currentRow++;
    }
    placeShape();
    clearRows();
    spawnBlock();
  }

  void clearRows() {
    for (int i = 0; i < rows; i++) {
      if (grid[i].every((cell) => cell > 0)) {
        setState(() {
          score += 10;
          grid[i] = List.filled(columns, 0);
        });
        for (int k = i - 1; k >= 0; k--) {
          grid[k + 1] = List.from(grid[k]);
        }
      }
    }
  }

  void moveBlockLeft() {
    if (canPlace(currentShape!, currentRow, currentCol - 1)) {
      setState(() {
        currentCol--;
      });
    }
  }

  void moveBlockRight() {
    if (canPlace(currentShape!, currentRow, currentCol + 1)) {
      setState(() {
        currentCol++;
      });
    }
  }

  void rotateBlock() {
    List<List<int>> rotatedShape = List.generate(currentShape![0].length,
        (i) => List.generate(currentShape!.length, (j) => currentShape![j][i]));
    for (int i = 0; i < rotatedShape.length; i++) {
      rotatedShape[i] = rotatedShape[i].reversed.toList();
    }

    if (canPlace(rotatedShape, currentRow, currentCol)) {
      setState(() {
        currentShape = rotatedShape;
      });
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Score: $score\nTry again!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      grid = List.generate(rows, (_) => List.filled(columns, 0));
      currentShape = null;
      startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tetris"),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text("Score: $score", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: columns / rows,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemCount: rows * columns,
                itemBuilder: (context, index) {
                  int row = index ~/ columns;
                  int col = index % columns;
                  int cellValue = grid[row][col];
                  bool isPartOfCurrentShape = false;

                  if (currentShape != null) {
                    for (int i = 0; i < currentShape!.length; i++) {
                      for (int j = 0; j < currentShape![i].length; j++) {
                        if (currentShape![i][j] == 1 &&
                            currentRow + i == row &&
                            currentCol + j == col) {
                          isPartOfCurrentShape = true;
                        }
                      }
                    }
                  }

                  return Container(
                    margin: EdgeInsets.all(1),
                    color: isPartOfCurrentShape
                        ? colors[currentColorIndex]
                        : (cellValue > 0
                            ? colors[cellValue - 1]
                            : Colors.white),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: moveBlockLeft,
              ),
              IconButton(
                icon: Icon(Icons.rotate_right),
                onPressed: rotateBlock,
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: moveBlockRight,
              ),
              ElevatedButton(
                onPressed: quickDrop,
                child: Text("Quick Drop"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }
}

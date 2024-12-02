import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({Key? key}) : super(key: key);

  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 20;
  static const int cols = 20;
  static const double squareSize = 20.0;

  List<Offset> snake = [const Offset(10, 10)];
  Offset food = const Offset(15, 15);
  String direction = 'up';
  Timer? gameLoopTimer;
  List<Particle> particles = []; // Store particles

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
        checkCollision();
        updateParticles();
      });
    });
  }

  void moveSnake() {
    Offset newHead;
    switch (direction) {
      case 'up':
        newHead = Offset(snake.first.dx, snake.first.dy - 1);
        break;
      case 'down':
        newHead = Offset(snake.first.dx, snake.first.dy + 1);
        break;
      case 'left':
        newHead = Offset(snake.first.dx - 1, snake.first.dy);
        break;
      case 'right':
      default:
        newHead = Offset(snake.first.dx + 1, snake.first.dy);
    }
    snake.insert(0, newHead);
    if (snake.first == food) {
      generateNewFood();
      spawnParticles(food);
    } else {
      snake.removeLast();
    }
  }

  void generateNewFood() {
    final random = Random();
    food = Offset(
      random.nextInt(cols).toDouble(),
      random.nextInt(rows).toDouble(),
    );
  }

  void checkCollision() {
    if (snake.first.dx < 0 ||
        snake.first.dx >= cols ||
        snake.first.dy < 0 ||
        snake.first.dy >= rows ||
        snake.sublist(1).contains(snake.first)) {
      gameLoopTimer?.cancel();
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Game Over', style: TextStyle(color: Colors.white)),
          content: Text(
            'Your score: ${snake.length - 1}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child:
                  const Text('Restart', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      snake = [const Offset(10, 10)];
      food = const Offset(15, 15);
      direction = 'up';
      particles.clear();
      startGame();
    });
  }

  void changeDirection(String newDirection) {
    if ((direction == 'up' && newDirection != 'down') ||
        (direction == 'down' && newDirection != 'up') ||
        (direction == 'left' && newDirection != 'right') ||
        (direction == 'right' && newDirection != 'left')) {
      direction = newDirection;
    }
  }

  void spawnParticles(Offset position) {
    for (int i = 0; i < 20; i++) {
      double angle = Random().nextDouble() * 2 * pi;
      double speed = Random().nextDouble() * 2 + 2;
      double xVelocity = cos(angle) * speed;
      double yVelocity = sin(angle) * speed;
      particles.add(Particle(
        position: position,
        velocity: Offset(xVelocity, yVelocity),
        lifetime: Random().nextDouble() * 0.6 + 0.4,
        color: Colors.yellow.withOpacity(Random().nextDouble() * 0.5 + 0.5),
      ));
    }
  }

  void updateParticles() {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].lifetime -= 0.05;
      particles[i].position += particles[i].velocity;
      if (particles[i].lifetime <= 0) {
        particles.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
        backgroundColor: Colors.green[800],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < 0) {
            changeDirection('up');
          } else if (details.primaryDelta! > 0) {
            changeDirection('down');
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta! < 0) {
            changeDirection('left');
          } else if (details.primaryDelta! > 0) {
            changeDirection('right');
          }
        },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            width: cols * squareSize,
            height: rows * squareSize,
            child: CustomPaint(
              painter: SnakeGamePainter(snake, food, particles),
            ),
          ),
        ),
      ),
    );
  }
}

class SnakeGamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final List<Particle> particles;

  SnakeGamePainter(this.snake, this.food, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.green, Colors.greenAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final foodPaint = Paint()..color = Colors.redAccent;

    for (var particle in particles) {
      final particlePaint = Paint()..color = particle.color;
      canvas.drawCircle(
        Offset(
          particle.position.dx * _SnakeGameScreenState.squareSize,
          particle.position.dy * _SnakeGameScreenState.squareSize,
        ),
        4.0,
        particlePaint,
      );
    }

    for (var segment in snake) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            segment.dx * _SnakeGameScreenState.squareSize,
            segment.dy * _SnakeGameScreenState.squareSize,
            _SnakeGameScreenState.squareSize,
            _SnakeGameScreenState.squareSize,
          ),
          const Radius.circular(8),
        ),
        snakePaint,
      );
    }

    canvas.drawCircle(
      Offset(
        food.dx * _SnakeGameScreenState.squareSize + 10,
        food.dy * _SnakeGameScreenState.squareSize + 10,
      ),
      8.0,
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  Offset position;
  Offset velocity;
  double lifetime;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.lifetime,
    required this.color,
  });
}

import 'dart:math';
import 'package:flutter/material.dart';

class Tetris extends StatefulWidget {
  const Tetris({Key? key}) : super(key: key);

  @override
  _TetrisState createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  int gridSize = 10;
  List<List<int>> gameGrid = [];
  Point<int> currentPosition = const Point(0, 4);
  int currentShape = 0;
  List<List<int>> shapes = [
    [0, 1, 0, 0, 1, 1, 0, 0, 0], // 
    [1, 1, 1, 1], // I
    [1, 1, 1, 0, 0, 0, 1], // L
    [1, 1, 0, 1, 1, 0, 0], // Z
    [1, 1, 1, 1, 0, 0, 0], // J
    [1, 1, 0, 0, 1, 1, 0], // S
    [1, 1, 1, 1, 1, 1, 0], // O
  ];
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    gameGrid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    currentPosition = const Point(0, 4);
    currentShape = Random().nextInt(shapes.length);
    gameOver = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => startGameLoop());
  }

  void startGameLoop() async {
    while (!gameOver) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          moveDown();
        });
      } else {
        break;
      }
    }
  }

  bool checkCollision(int row, int col, List<int> shape) {
    int shapeSize = sqrt(shape.length).toInt();
    for (int i = 0; i < shapeSize; i++) {
      for (int j = 0; j < shapeSize; j++) {
        if (shape[i * shapeSize + j] == 1) {
          int gridRow = row + i;
          int gridCol = col + j;

          if (gridRow >= gridSize || gridCol < 0 || gridCol >= gridSize || gameGrid[gridRow][gridCol] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void mergeShapeToGrid() {
    int shapeSize = sqrt(shapes[currentShape].length).toInt();
    for (int i = 0; i < shapeSize; i++) {
      for (int j = 0; j < shapeSize; j++) {
        if (shapes[currentShape][i * shapeSize + j] == 1) {
          gameGrid[currentPosition.x + i][currentPosition.y + j] = 1;
        }
      }
    }
    clearLines();
    currentPosition = const Point(0, 4);
    currentShape = Random().nextInt(shapes.length);
    if (checkCollision(currentPosition.x, currentPosition.y, shapes[currentShape])) {
      gameOver = true;
    }
  }

  void clearLines() {
    for (int i = 0; i < gridSize; i++) {
      if (gameGrid[i].every((cell) => cell != 0)) {
        gameGrid.removeAt(i);
        gameGrid.insert(0, List.filled(gridSize, 0));
      }
    }
  }

  void moveLeft() {
    if (!checkCollision(currentPosition.x, currentPosition.y - 1, shapes[currentShape])) {
      currentPosition = Point(currentPosition.x, currentPosition.y - 1);
    }
  }

  void moveRight() {
    if (!checkCollision(currentPosition.x, currentPosition.y + 1, shapes[currentShape])) {
      currentPosition = Point(currentPosition.x, currentPosition.y + 1);
    }
  }

  void moveDown() {
    if (!checkCollision(currentPosition.x + 1, currentPosition.y, shapes[currentShape])) {
      currentPosition = Point(currentPosition.x + 1, currentPosition.y);
    } else {
      mergeShapeToGrid();
    }
  }

  Widget buildGrid() {
    return Column(
      children: List.generate(gridSize, (row) => Row(
        children: List.generate(gridSize, (col) {
          bool isCurrentShape = false;
          int shapeSize = sqrt(shapes[currentShape].length).toInt();
          if (currentPosition.x <= row && row < currentPosition.x + shapeSize &&
              currentPosition.y <= col && col < currentPosition.y + shapeSize) {
            int shapeRow = row - currentPosition.x;
            int shapeCol = col - currentPosition.y;
            if (shapeRow >= 0 && shapeRow < shapeSize && shapeCol >= 0 && shapeCol < shapeSize) {
              if (shapes[currentShape][shapeRow * shapeSize + shapeCol] == 1) {
                isCurrentShape = true;
              }
            }
          }

          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: gameGrid[row][col] == 1 || isCurrentShape ? Colors.blue : Colors.grey,
              border: Border.all(color: Colors.black, width: 0.1),
            ),
          );
        }),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('俄罗斯方块'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildGrid(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: moveLeft, child: const Text('Left')),
                ElevatedButton(onPressed: moveRight, child: const Text('Right')),
                ElevatedButton(onPressed: moveDown, child: const Text('Down')),
              ],
            ),
            if (gameOver) Text("游戏结束!"),
            ElevatedButton(
              onPressed: initializeGame,
              child: const Text("重新开始"),
            ),
          ],
        ),
      ),
    );
  }
}

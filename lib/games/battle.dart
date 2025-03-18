import 'package:flutter/material.dart';
import 'dart:math';

class Battle extends StatefulWidget {
  const Battle({Key? key}) : super(key: key);

  @override
  _BattleState createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  List<List<bool>> playerGrid = [];
  List<List<bool>> aiGrid = [];
  List<Point<int>> playerShips = [];
  List<Point<int>> aiShips = [];
  bool gameOver = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    playerGrid = List.generate(10, (_) => List.filled(10, false));
    aiGrid = List.generate(10, (_) => List.filled(10, false));
    playerShips = [];
    aiShips = [];
    gameOver = false;
    message = "";
    placeShips(playerGrid, playerShips);
    placeShips(aiGrid, aiShips);
  }

  void placeShips(List<List<bool>> grid, List<Point<int>> ships) {
    Random random = Random();
    for (int i = 0; i < 3; i++) { // 3艘
      int row, col;
      do {
        row = random.nextInt(10);
        col = random.nextInt(10);
      } while (grid[row][col]); // 防止重复覆盖

      grid[row][col] = true;
      ships.add(Point(row, col));
    }
  }

  void fire(int row, int col, List<List<bool>> targetGrid, List<Point<int>> targetShips, bool isPlayerFiring) {
    if (gameOver) return;

    setState(() {
      if (targetGrid[row][col]) {
        targetGrid[row][col] = false; // 打中了
        targetShips.removeWhere((ship) => ship.x == row && ship.y == col);
        message = isPlayerFiring ? "击中了！!" : "AI击中!";
        if (targetShips.isEmpty) {
          gameOver = true;
          message = isPlayerFiring ? "你赢了!" : "AI 赢了!";
        }
      } else {
        message = isPlayerFiring ? "错过了目标!" : "AI 错过了目标!";
      }

      if (!isPlayerFiring && !gameOver) {
        aiFire();
      }
    });
  }

  void aiFire() {
    Random random = Random();
    int row, col;
    do {
      row = random.nextInt(10);
      col = random.nextInt(10);
    } while (!playerGrid[row][col] && playerShips.any((ship) => ship.x == row && ship.y == col)); // Avoid firing at the same spot

    fire(row, col, playerGrid, playerShips, false);
  }

  Widget buildGrid(List<List<bool>> grid, bool isPlayerGrid) {
    return Column(
      children: List.generate(10, (row) => Row(
        children: List.generate(10, (col) =>
            GestureDetector(
              onTap: () {
                if (!isPlayerGrid) {
                  fire(row, col, aiGrid, aiShips, true);
                }
              },
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: grid[row][col]
                      ? (isPlayerGrid ? Colors.blue : Colors.red) // 展示自己的船只
                      : Colors.grey,
                  border: Border.all(color: Colors.black, width: 0.2),
                ),
              ),
            )
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI人机对战'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("AI区域"),
            buildGrid(aiGrid, false),
            const SizedBox(height: 20),
            const Text("你的区域"),
            buildGrid(playerGrid, true),
            Text(message),
            ElevatedButton(
              onPressed: initializeGame,
              child: const Text("再来一局"),
            ),
          ],
        ),
      ),
    );
  }
}

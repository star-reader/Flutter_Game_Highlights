import 'dart:math';
import 'package:flutter/material.dart';

class Minesweeper extends StatefulWidget {
  const Minesweeper({Key? key}) : super(key: key);

  @override
  _MinesweeperState createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  int _gridSize = 10;
  int _numberOfMines = 15;
  List<List<Cell>> _grid = [];
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    _gameOver = false;
    _grid = List.generate(_gridSize, (row) => List.generate(_gridSize, (col) => Cell(row, col)));
    _placeMines();
    _calculateNeighboringMines();
  }

  void _placeMines() {
    Random random = Random();
    int minesPlaced = 0;
    while (minesPlaced < _numberOfMines) {
      int row = random.nextInt(_gridSize);
      int col = random.nextInt(_gridSize);
      if (!_grid[row][col].isMine) {
        _grid[row][col].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateNeighboringMines() {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (!_grid[row][col].isMine) {
          int count = 0;
          for (int i = max(0, row - 1); i <= min(_gridSize - 1, row + 1); i++) {
            for (int j = max(0, col - 1); j <= min(_gridSize - 1, col + 1); j++) {
              if (_grid[i][j].isMine) {
                count++;
              }
            }
          }
          _grid[row][col].neighboringMines = count;
        }
      }
    }
  }

  void _revealCell(int row, int col) {
    if (_gameOver || _grid[row][col].isRevealed) return;

    setState(() {
      _grid[row][col].isRevealed = true;

      if (_grid[row][col].isMine) {
        _gameOver = true;
        _revealAllMines();
        _showGameOverDialog(context, "You Lost!");
        return;
      }

      if (_grid[row][col].neighboringMines == 0) {
        for (int i = max(0, row - 1); i <= min(_gridSize - 1, row + 1); i++) {
          for (int j = max(0, col - 1); j <= min(_gridSize - 1, col + 1); j++) {
            if (!_grid[i][j].isRevealed) {
              _revealCell(i, j);
            }
          }
        }
      }
      if (_checkWinCondition()) {
        _gameOver = true;
        _showGameOverDialog(context, "You Won!");
      }
    });
  }

  bool _checkWinCondition() {
    int unrevealedCount = 0;
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (!_grid[row][col].isRevealed && !_grid[row][col].isMine) {
          unrevealedCount++;
        }
      }
    }
    return unrevealedCount == 0;
  }

  void _revealAllMines() {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (_grid[row][col].isMine) {
          _grid[row][col].isRevealed = true;
        }
      }
    }
  }

  void _showGameOverDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: const Text("Play again?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGrid();
                });
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Grid(
              grid: _grid,
              gridSize: _gridSize,
              onCellTap: _revealCell,
            ),
          ),
        ),
      ),
    );
  }
}

class Grid extends StatelessWidget {
  final List<List<Cell>> grid;
  final int gridSize;
  final Function(int, int) onCellTap;

  const Grid({Key? key, required this.grid, required this.gridSize, required this.onCellTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(gridSize, (row) => Row(
        children: List.generate(gridSize, (col) =>
            CellWidget(
              cell: grid[row][col],
              onTap: () => onCellTap(row, col),
            )
        ),
      )),
    );
  }
}

class Cell {
  int row;
  int col;
  bool isMine;
  bool isRevealed;
  int neighboringMines;

  Cell(this.row, this.col, {this.isMine = false, this.isRevealed = false, this.neighboringMines = 0});
}

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;

  const CellWidget({Key? key, required this.cell, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: cell.isRevealed
                ? (cell.isMine ? Colors.red : Colors.white)
                : Colors.grey[300],
          ),
          child: Center(
            child: cell.isRevealed
                ? (cell.isMine
                ? const Text("💣", style: TextStyle(fontSize: 20))
                : (cell.neighboringMines > 0
                ? Text(
              cell.neighboringMines.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getColorForMineCount(cell.neighboringMines),
              ),
            )
                : null))
                : null,
          ),
        ),
      ),
    );
  }

  Color _getColorForMineCount(int count) {
    switch (count) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.brown;
      default:
        return Colors.black;
    }
  }
}

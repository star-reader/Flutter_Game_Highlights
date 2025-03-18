import 'package:flutter/material.dart';
import './games/minesweeper.dart';
import 'games/battle.dart';
import 'games/tetris.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Plays',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Widget _selectedGame = const Minesweeper();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _selectedGame = const Minesweeper();
          break;
        case 1:
          _selectedGame = const Battle();
          break;
        case 2:
          _selectedGame = const Tetris();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Plays'),
      ),
      body: _selectedGame,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '扫雷',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: '人机对战',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: '俄罗斯方块',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class GreenTileGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const GreenTileGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<GreenTileGameScreen> createState() => _GreenTileGameScreenState();
}



class _GreenTileGameScreenState extends State<GreenTileGameScreen> {
  int score = 0;
  late int remainingTime;

  Timer? gameTimer;
  Timer? tileTimer;

  int greenIndex = 0;
  bool canTap = true;

  final int tileChangeMs = 650;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    makeNewGreenTile();
    startGameTimer();
    startTileTimer();
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        gameTimer?.cancel();
        tileTimer?.cancel();
        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void startTileTimer() {
    tileTimer = Timer.periodic(Duration(milliseconds: tileChangeMs), (_) {
      setState(() {
        makeNewGreenTile();
      });
    });
  }

  void makeNewGreenTile() {
    greenIndex = Random().nextInt(9);
    canTap = true;
  }

  void tapTile(int index) {
    setState(() {
      if (index == greenIndex && canTap) {
        score++;
        makeNewGreenTile();
      } 
    });
  }

  String decidePunishment() {
    final randomPunishments = [
      '음료수 사기',
      '편의점 다녀오기',
      '노래 한 소절 부르기',
      '애교하기',
      '다음 판 방장하기',
    ];

    if (widget.punishmentType == '랜덤 벌칙') {
      return randomPunishments[Random().nextInt(randomPunishments.length)];
    }

    if (widget.punishmentType == '팀장이 직접 선택') {
      return '팀장이 고른 벌칙';
    }

    return '직접 입력한 벌칙';
  }

  void goToResultScreen() {
    final random = Random();

    final results = widget.players.map((name) {
      if (name == '나') {
        return PlayerResult(name, score);
      }

      return PlayerResult(name, random.nextInt(25));
    }).toList();

    results.sort((a, b) => b.score.compareTo(a.score));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          results: results,
          punishmentType: widget.punishmentType,
          punishment: decidePunishment(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    tileTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('초록칸게임'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              '점수: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '초록칸을 빠르게 눌러!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(9, (index) {
                  final isGreen = index == greenIndex;

                  return GestureDetector(
                    onTap: () => tapTile(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isGreen
                            ? Colors.green
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


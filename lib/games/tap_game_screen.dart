import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class TapGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const TapGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<TapGameScreen> createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen> {
  int score = 0;
  late int remainingTime;
  Timer? timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        timer?.cancel();

        setState(() {
          remainingTime = 0;
          isGameOver = true;
        });

        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void increaseScore() {
    if (isGameOver) return;

    setState(() {
      score++;
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
      return PlayerResult(name, random.nextInt(80) + 40);
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
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('연타게임'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 20),
            Text(
              '점수: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: increaseScore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 220),
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
              ),
              child: const Text('TAP!', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}


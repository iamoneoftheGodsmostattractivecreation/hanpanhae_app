import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class RhythmGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const RhythmGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends State<RhythmGameScreen> {
  int score = 0;
  late int remainingTime;

  Timer? gameTimer;
  Timer? noteTimer;

  double noteY = -80;
  bool noteActive = false;

  final double hitLineY = 420;
  final double hitRange = 55;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    startGameTimer();
    spawnNote();
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        gameTimer?.cancel();
        noteTimer?.cancel();
        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void spawnNote() {
    noteY = -80;
    noteActive = true;

    noteTimer?.cancel();
    noteTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        noteY += 5;
      });

      if (noteY > 620) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            spawnNote();
          }
        });
      }
    });
  }

  void tapBeat() {
    if (!noteActive) return;

    final diff = (noteY - hitLineY).abs();

    setState(() {
      if (diff <= hitRange) {
        score++;
        noteActive = false;
        noteTimer?.cancel();

        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            spawnNote();
          }
        });
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

      return PlayerResult(name, random.nextInt(20));
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
    noteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('리듬게임'),
      ),
      body: GestureDetector(
        onTap: tapBeat,
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 24,
              child: Text(
                '남은 시간: $remainingTime초',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 24,
              child: Text(
                '점수: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '원이 선에 닿을 때 TAP!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            Positioned(
              top: hitLineY,
              left: 40,
              right: 40,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            if (noteActive)
              Positioned(
                top: noteY,
                left: MediaQuery.of(context).size.width / 2 - 35,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '♪',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: tapBeat,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 70),
                    backgroundColor: Colors.white,
                    foregroundColor: bgColor,
                  ),
                  child: const Text(
                    'TAP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
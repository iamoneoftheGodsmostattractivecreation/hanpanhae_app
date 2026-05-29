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
  Timer? beatTimer;

  bool isBeatTime = false;
  int lastBeatTime = 0;

  final int beatIntervalMs = 900;
  final int successRangeMs = 250;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    startGameTimer();
    startBeatTimer();
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        gameTimer?.cancel();
        beatTimer?.cancel();
        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void startBeatTimer() {
    beatTimer = Timer.periodic(
      Duration(milliseconds: beatIntervalMs),
      (_) {
        setState(() {
          isBeatTime = true;
          lastBeatTime = DateTime.now().millisecondsSinceEpoch;
        });

        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {
              isBeatTime = false;
            });
          }
        });
      },
    );
  }

  void tapBeat() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = (now - lastBeatTime).abs();

    setState(() {
      if (diff <= successRangeMs) {
        score++;
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

      return PlayerResult(name, random.nextInt(20) - 5);
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
    beatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isBeatTime ? Colors.green : bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('리듬게임'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
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
            const SizedBox(height: 60),
            Text(
              isBeatTime ? 'BEAT!' : '기다려...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: tapBeat,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 220),
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
              ),
              child: const Text(
                'TAP',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
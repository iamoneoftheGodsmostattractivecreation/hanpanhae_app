import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

import '../models/player_result.dart';
import '../screens/result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TapGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String roomcode;
  final String myName;

  const TapGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.roomcode,
    required this.myName,
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

  Future<void> goToResultScreen() async {
    await saveResult(score);

    while (true) {
      final results = await loadResults();

      if (results.length >= widget.players.length) {
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
        break;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
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
      '골라준 사진으로 프로필사진 변경하기'
    ];

    if (widget.punishmentType == '랜덤 벌칙') {
      return randomPunishments[Random().nextInt(randomPunishments.length)];
    }

    if (widget.punishmentType == '팀장이 직접 선택') {
      return '팀장이 고른 벌칙';
    }

    return '직접 입력한 벌칙';
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

  Future<void> saveResult(int score) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .collection('results')
        .doc(widget.myName)
        .set({
      'name': widget.myName,
      'score': score,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<PlayerResult>> loadResults() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .collection('results')
        .get();

    final results = snapshot.docs.map((doc) {
      final data = doc.data();

      return PlayerResult(
        data['name'],
        data['score'],
      );
    }).toList();

    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}

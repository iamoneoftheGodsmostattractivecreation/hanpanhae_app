import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class WrongWordGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const WrongWordGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<WrongWordGameScreen> createState() =>
      _WrongWordGameScreenState();
}

class _WrongWordGameScreenState
    extends State<WrongWordGameScreen> {
  int score = 0;
  late int remainingTime;
  Timer? timer;
  int answerIndex = 0;

  final List<Map<String, String>> questions = [
    {'normal': '사과', 'wrong': '사괴'},
    {'normal': '고양이', 'wrong': '고양히'},
    {'normal': '학교', 'wrong': '학고'},
    {'normal': '친구', 'wrong': '친쿠'},
    {'normal': '바나나', 'wrong': '바냐나'},
  ];

  late Map<String, String> currentQuestion;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    makeNewQuestion();
    startTimer();
  }

  void makeNewQuestion() {
    final random = Random();

    currentQuestion =
        questions[random.nextInt(questions.length)];

    answerIndex = random.nextInt(9);
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (remainingTime <= 1) {
          timer?.cancel();

          goToResultScreen();
        } else {
          setState(() {
            remainingTime--;
          });
        }
      },
    );
  }

  void selectCell(int index) {
    setState(() {
      if (index == answerIndex) {
        score++;
      } else {
        score--;
      }

      makeNewQuestion();
    });
  }

  String decidePunishment() {
    final randomPunishments = [
      '음료수 사기',
      '편의점 다녀오기',
      '노래 부르기',
      '애교하기',
    ];

    return randomPunishments[
        Random().nextInt(randomPunishments.length)];
  }

  void goToResultScreen() {
    final random = Random();

    final results = widget.players.map((name) {
      if (name == '나') {
        return PlayerResult(name, score);
      }

      return PlayerResult(
        name,
        random.nextInt(8) + 1,
      );
    }).toList();

    results.sort(
      (a, b) => b.score.compareTo(a.score),
    );

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
        title: const Text('틀린말찾기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
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

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(9, (index) {
                  final word =
                      index == answerIndex
                          ? currentQuestion['wrong']!
                          : currentQuestion['normal']!;

                  return GestureDetector(
                    onTap: () => selectCell(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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


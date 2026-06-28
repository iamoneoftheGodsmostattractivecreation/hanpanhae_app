import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WrongWordGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String roomcode;
  final String myName;

  const WrongWordGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.roomcode,
    required this.myName,
  });

  @override
  State<WrongWordGameScreen> createState() => _WrongWordGameScreenState();
}

class _WrongWordGameScreenState extends State<WrongWordGameScreen> {
  int score = 0;
  late int remainingTime;
  Timer? timer;
  int answerIndex = 0;

  final List<Map<String, String>> questions = [
    {'normal': '사과', 'wrong': '사괴'},
    {'normal': '고양이', 'wrong': '고앙이'},
    {'normal': '학교', 'wrong': '학고'},
    {'normal': '친구', 'wrong': '친궁'},
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

    currentQuestion = questions[random.nextInt(questions.length)];

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
      }

      makeNewQuestion();
    });
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
                  final word = index == answerIndex
                      ? currentQuestion['wrong']!
                      : currentQuestion['normal']!;

                  return GestureDetector(
                    onTap: () => selectCell(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
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

  Future<String> loadFinalPunishment() async {
    final roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .get();

    final data = roomDoc.data() as Map<String, dynamic>;

    return data['finalPunishment'] ?? '벌칙 없음';
  }

  Future<void> goToResultScreen() async {
    await saveResult(score);

    while (true) {
      final results = await loadResults();

      if (results.length >= widget.players.length) {
        final finalPunishment = await loadFinalPunishment();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              results: results,
              punishmentType: widget.punishmentType,
              punishment: finalPunishment,
            ),
          ),
        );
        break;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class RhythmGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String roomcode;
  final String myName;

  const RhythmGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.roomcode,
    required this.myName,
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

  @override
  void dispose() {
    gameTimer?.cancel();
    noteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          title: const Text('리듬게임'),
          automaticallyImplyLeading: false,
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
              roomcode: widget.roomcode,
              myName: widget.myName,
            ),
          ),
        );
        break;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

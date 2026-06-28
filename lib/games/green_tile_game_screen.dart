import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class GreenTileGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String roomcode;
  final String myName;

  const GreenTileGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.roomcode,
    required this.myName,
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

  @override
  void dispose() {
    gameTimer?.cancel();
    tileTimer?.cancel();
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
          title: const Text('초록칸게임'),
          automaticallyImplyLeading: false,
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

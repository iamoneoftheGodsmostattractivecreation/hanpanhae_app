import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class PictureCategoryScreen extends StatelessWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String roomcode;
  final String myName;

  const PictureCategoryScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.roomcode,
    required this.myName,
  });

  void startGame(BuildContext context, String category) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PictureGuessGameScreen(
          gameTime: gameTime,
          players: players,
          punishmentType: punishmentType,
          category: category,
          roomcode: roomcode,
          myName: myName,
        ),
      ),
    );
  }

  Widget categoryButton(BuildContext context, String title, String emoji) {
    return GestureDetector(
      onTap: () => startGame(context, title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('카테고리 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '어떤 그림 맞출까?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            categoryButton(context, '동물', '🐶'),
            categoryButton(context, '사물', '📦'),
            categoryButton(context, '애니캐릭터', '✨'),
          ],
        ),
      ),
    );
  }
}

class PictureGuessGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;
  final String category;
  final String roomcode;
  final String myName;

  const PictureGuessGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.category,
    required this.roomcode,
    required this.myName,
  });

  @override
  State<PictureGuessGameScreen> createState() => _PictureGuessGameScreenState();
}

class _PictureGuessGameScreenState extends State<PictureGuessGameScreen> {
  int score = 0;
  late int remainingTime;
  Timer? gameTimer;
  Timer? questionTimer;
  int questionRemainingTime = 5;

  final TextEditingController answerController = TextEditingController();
  final FocusNode answerFocusNode = FocusNode();

  late List<Map<String, String>> questions;
  late Map<String, String> currentQuestion;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    questions = getQuestions();
    makeNewQuestion();
    startGameTimer();
  }

  List<Map<String, String>> getQuestions() {
    if (widget.category == '동물') {
      return [
        {'emoji': '🐜', 'answer': '개미핥기'},
        {'emoji': '🦌', 'answer': '꽃사슴'},
        {'emoji': '🪳', 'answer': '바퀴벌레'},
        {'emoji': '🐛', 'answer': '지네'},
        {'emoji': '🦔', 'answer': '고슴도치'},
        {'emoji': '🦦', 'answer': '수달'},
        {'emoji': '🦥', 'answer': '나무늘보'},
        {'emoji': '🦨', 'answer': '스컹크'},
      ];
    }

    if (widget.category == '사물') {
      return [
        {'emoji': '📱', 'answer': '핸드폰'},
        {'emoji': '💻', 'answer': '노트북'},
        {'emoji': '⌚', 'answer': '시계'},
        {'emoji': '🎧', 'answer': '헤드폰'},
        {'emoji': '📷', 'answer': '카메라'},
        {'emoji': '🧯', 'answer': '소화기'},
        {'emoji': '🪤', 'answer': '쥐덫'},
        {'emoji': '🪚', 'answer': '톱'},
        {'emoji': '🧲', 'answer': '자석'},
        {'emoji': '🪝', 'answer': '갈고리'},
        {'emoji': '🧬', 'answer': 'DNA'},
      ];
    }

    return [
      {'emoji': '👒', 'answer': '루피'},
      {'emoji': '⚔️', 'answer': '조로'},
      {'emoji': '🍥', 'answer': '나루토'},
      {'emoji': '🟠', 'answer': '손오공'},
      {'emoji': '👓', 'answer': '코난'},
    ];
  }

  void makeNewQuestion() {
    questionTimer?.cancel();

    setState(() {
      currentQuestion = questions[Random().nextInt(questions.length)];
      answerController.clear();
      answerFocusNode.requestFocus();
      questionRemainingTime = 5;
    });

    questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;
        if (questionRemainingTime <= 1) {
          timer.cancel();
          makeNewQuestion();
        } else {
          setState(() {
            questionRemainingTime--;
          });
        }
      },
    );
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        gameTimer?.cancel();
        questionTimer?.cancel();
        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void checkAnswer() {
    final userAnswer = answerController.text.trim();
    final correctAnswer = currentQuestion['answer']!;

    if (userAnswer == correctAnswer) {
      score++;
    }
    makeNewQuestion();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    questionTimer?.cancel();
    answerController.dispose();
    answerFocusNode.dispose();
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
          title: Text('그림맞추기 - ${widget.category}'),
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
              const SizedBox(height: 12),
              Text(
                '문제 제한시간: $questionRemainingTime초',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                currentQuestion['emoji']!,
                style: const TextStyle(fontSize: 100),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: answerController,
                focusNode: answerFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: InputDecoration(
                  hintText: '정답 입력',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => checkAnswer(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.white,
                  foregroundColor: bgColor,
                ),
                child: const Text('정답 제출', style: TextStyle(fontSize: 18)),
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

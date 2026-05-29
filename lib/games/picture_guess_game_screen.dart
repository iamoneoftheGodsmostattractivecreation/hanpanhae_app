import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/player_result.dart';
import '../screens/result_screen.dart';

class PictureCategoryScreen extends StatelessWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const PictureCategoryScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
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

  const PictureGuessGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
    required this.category,
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
      return PlayerResult(name, random.nextInt(10));
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
    questionTimer?.cancel();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: Text('그림맞추기 - ${widget.category}'),
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
            Text( '문제 제한시간: $questionRemainingTime초',
              style: const TextStyle( 
              color: Colors.white70, 
              fontSize: 20, ), 
            ),
            const SizedBox(height: 50),
            Text(
              currentQuestion['emoji']!,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: answerController,
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
    );
  }
}
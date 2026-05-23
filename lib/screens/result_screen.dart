import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';

class ResultScreen extends StatelessWidget {
  final List<PlayerResult> results;
  final String punishmentType;
  final String punishment;

  const ResultScreen({
    super.key,
    required this.results,
    required this.punishmentType,
    required this.punishment,
  });

  @override
  Widget build(BuildContext context) {
    final loser = results.last;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              '게임 결과',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final player = results[index];

                  String rankIcon = '';
                  if (index == 0) rankIcon = '🥇';
                  if (index == 1) rankIcon = '🥈';
                  if (index == 2) rankIcon = '🥉';
                  if (index >= 3) rankIcon = '😵';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Text(rankIcon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${player.score}점',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text(
              '꼴찌: ${loser.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '벌칙 방식: $punishmentType',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '벌칙: $punishment',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 56),
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
              ),
              child: const Text('홈으로', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
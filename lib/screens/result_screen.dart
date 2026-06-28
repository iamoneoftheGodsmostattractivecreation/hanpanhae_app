import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/player_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class ResultScreen extends StatelessWidget {
  final List<PlayerResult> results;
  final String punishmentType;
  final String punishment;
  final String roomcode;
  final String myName;

  const ResultScreen({
    super.key,
    required this.results,
    required this.punishmentType,
    required this.punishment,
    required this.roomcode,
    required this.myName,
  });

  @override
  Widget build(BuildContext context) {
    final loser = results.last;
    final roomRef =
        FirebaseFirestore.instance.collection('rooms').doc(roomcode);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('결과'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: roomRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final host = data['host'] ?? '';
          final isHost = myName == host;
          final roomState = data['roomState'] ?? '';

          if (roomState == 'time_select') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TimeSelectScreen(
                    players: results.map((result) => result.name).toList(),
                    punishmentType: data['punishmentType'] ?? punishmentType,
                    selectedGame: data['selectedGame'] ?? '',
                    roomcode: roomcode,
                    myName: myName,
                  ),
                ),
              );
            });
          }

          return Padding(
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
                            Text(
                              rankIcon,
                              style: const TextStyle(fontSize: 28),
                            ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isHost)
                      ElevatedButton(
                        onPressed: () async {
                          await roomRef.update({
                            'roomState': 'time_select',
                            'gameStarted': false,
                            'finalPunishment': '',
                            'gameTime': 30,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 56),
                          backgroundColor: Colors.white,
                          foregroundColor: bgColor,
                        ),
                        child: const Text('다시하기'),
                      ),
                    if (isHost) const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 56),
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('홈으로'),
                    ),
                  ],
                ),
                if (!isHost) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '방장이 다시 시작할 때까지 기다리는 중...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'games/tap_game_screen.dart';
import 'games/wrong_word_game_screen.dart';
import 'games/rhythm_game_screen.dart';
import 'games/green_tile_game_screen.dart';
import 'games/picture_guess_game_screen.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/chat_box.dart';

// TODO: 닉네임 입력 Dialog 만들기
// TODO: host 표시
// TODO: readyPlayers 연결
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //MyApp 객체 생성 가능하게해주는코드

  @override //부모 클래스 함수를 재정의flu한다
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, //오른쪽 위 DEBUG 배너 제거
      home: HomeScreen(), //앱 첫 화면은 HomeScreen으로 해라
    );
  }
}

// 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); //HomeScreen 객체 생성 가능하게 해주는 코드

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '한판해',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    createRoom(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 60),
                    backgroundColor: Colors.white,
                    foregroundColor: bgColor,
                  ),
                  child: const Text('방 만들기', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      showJoinRoomDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 60),
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('입장하기', style: TextStyle(fontSize: 20))),
              ],
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: ChatBox(roomcode: 'global'),
          ),
        ],
      ),
    );
  }

  String makeRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> createRoom(BuildContext context) async {
    print("1");
    try {
      final roomcode = makeRoomCode();
      final hostName = '플레이어${Random().nextInt(999)}';
      print("2");
      await FirebaseFirestore.instance.collection('rooms').doc(roomcode).set({
        'roomCode': roomcode,
        'players': ['플레이어${Random().nextInt(999)}'],
        'host': hostName,
        'readyPlayers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'selectedGame': '',
        'gameStarted': false,
      });
      print("3");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupSetupScreen(
            roomcode: roomcode,
          ),
        ),
      );
    } catch (e) {
      print('방 만들기 에러: $e');
    }
  }

  void showJoinRoomDialog(BuildContext context) {
    final TextEditingController roomCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('방 코드 입력'),
          content: TextField(
            controller: roomCodeController,
            decoration: const InputDecoration(
              hintText: '예: JLP3J2',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final roomcode = roomCodeController.text.trim().toUpperCase();
                print('입력한 방코드: $roomcode');

                final roomDoc = await FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomcode)
                    .get();

                print('방 존재함? ${roomDoc.exists}');

                if (roomDoc.exists) {
                  await FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(roomcode)
                      .update({
                    'players': FieldValue.arrayUnion(['친구']),
                  });
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WaitingRoomScreen(
                        roomcode: roomcode,
                      ),
                    ),
                  );
                } else {
                  print('없는 방 코드');
                }
              },
              child: const Text('입장'),
            ),
          ],
        );
      },
    );
  }
}

// 그룹 설정 화면 (친구 추가됨, 플레이어목록 변함)
class GroupSetupScreen extends StatefulWidget {
  final String roomcode;

  const GroupSetupScreen({
    super.key,
    required this.roomcode,
  });

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  final List<String> players = ['나']; //players 리스트 길이 1

  void addFriend() {
    setState(() {
      players.add('친구 ${players.length}'); //친구 1 추가 , $ : 문자열 안에 변수 넣기
    });
  }

  void addNearbyPerson() {
    setState(() {
      players.add('근처 사람 ${players.length}'); //근처 사람 1 추가
    });
  }

  void goToGameSelect() {
    Navigator.push(
      context, //현재 화면 정보
      MaterialPageRoute(
        //게임 선택 화면으로 이동하는 함수
        builder: (_) => GameSelectScreen(
          players: players,
          roomcode: widget.roomcode,
        ), //이동할 화면을 생성하고, 현재 players 리스트를 다음 화면으로 넘김
      ),
    );
  }

  @override //부모함수재정의
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold에는 배경, appbar, body 같은 걸 담는다.
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text(
            '그룹 설정'), //그룹 설정이라는 텍스트값을 계속 띄울 수 있게 하려고(고정이니까) const를 쓰는 거임
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '같이 할 사람을 모아줘',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: addNearbyPerson,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          backgroundColor: Colors.white,
                          foregroundColor: bgColor,
                        ),
                        child: const Text('근처 사람 추가'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: addFriend,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('친구 초대'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: bgColor,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                players[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Text(
                              'READY',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: goToGameSelect,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.white,
                    foregroundColor: bgColor,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: ChatBox(roomcode: widget.roomcode),
            //const는 앱 실행 전에 이미 값이 확정되는 것에만 붙일 수 있어.
            //근데 widget.roomcode는:
            //방 만들기 누름
            //→ 랜덤 roomcode 생성
            //→ 다음 화면으로 전달

            //처럼 앱 실행 중에 정해지는 값이잖아.
            //const Positioned = 미리 만들어야 함
            //widget.roomcode = 실행해봐야 앎
          ),
        ],
      ),
    );
  }
}

// 게임 선택 화면
class GameSelectScreen extends StatefulWidget {
  final List<String> players;
  final String roomcode;

  const GameSelectScreen({
    super.key,
    required this.players,
    required this.roomcode,
  }); //required : 이 값 반드시 넣어야함

  @override
  State<GameSelectScreen> createState() =>
      _GameSelectScreenState(); //GameSelectedScreen의 상태는 _GameSelectScreenState가 담당한다
} // _ 가 앞에 붙는 이유는 이 파일 내부에서만 사용 가능(private) 이라는 Dart 문법 ! 외부에서 막 쓰지말라는 뜻

class _GameSelectScreenState extends State<GameSelectScreen> {
  String selectedGame = '연타게임';

  Future<void> goToPunishmentSelect() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .update({
      'selectedGame': selectedGame,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PunishmentSelectScreen(
          players: widget.players,
          selectedGame: selectedGame,
          roomcode: widget.roomcode,
        ),
      ),
    );
  }

  Widget gameButton(String gameName) {
    final selected = selectedGame == gameName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGame = gameName;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              gameName == '연타게임' // 게임 이름이 연타게임인가?
                  ? '👆' //맞으면 손가락 이모지 출력
                  : gameName == '틀린말찾기'
                      ? '👀'
                      : gameName == '초록칸누르기'
                          ? '🟩'
                          : gameName == '그림맞추기'
                              ? '🖼️'
                              : '🎵',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Text(
              gameName,
              style: TextStyle(
                color: selected ? bgColor : Colors.white,
                fontSize: 22,
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
        title: const Text('게임 선택'),
      ),
      body: Padding(
        //위젯이름이 Padding인거임
        padding: const EdgeInsets.all(
            24), // Padding 위젯의 속성: 안의 내용물을 상하좌우 24만큼 안쪽으로 밀어라
        child: Stack(
          //겹쳐놓는 화면구조
          children: [
            Column(
              //세로로 나열하는 문법
              crossAxisAlignment:
                  CrossAxisAlignment.start, //가로축 기준 시작점(왼쪽)으로 정렬하라
              children: [
                const Text(
                  '어떤 게임 할까?', //이 글자는 고정
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                gameButton('연타게임'),
                gameButton('리듬게임'),
                gameButton('틀린말찾기'),
                gameButton('초록칸누르기'),
                gameButton('그림맞추기')
              ],
            ),
            Positioned(
              //정확환 위치 지정하는 문법
              right: 0, //오른쪽 끝에 붙여라
              bottom: 0, // 아래끝에 붙여라           결과적으로 오른쪽 아래끝에 버튼 생김!!
              child: ElevatedButton(
                //배치할 실제 위젯
                onPressed: goToPunishmentSelect,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 56),
                  backgroundColor: Colors.white,
                  foregroundColor: bgColor,
                ),
                child: const Text('입장'),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: ChatBox(roomcode: widget.roomcode),
            ),
          ],
        ),
      ),
    );
  }
}

// 벌칙 설정 화면
class PunishmentSelectScreen extends StatefulWidget {
  final List<String> players; //final: 실행중에결정되어 그뒤로 못바꾸는문법
  final String selectedGame;
  final String roomcode;
  const PunishmentSelectScreen({
    super.key,
    required this.players,
    required this.selectedGame,
    required this.roomcode,
  });

  @override
  State<PunishmentSelectScreen> createState() => _PunishmentSelectScreenState();
}

class _PunishmentSelectScreenState extends State<PunishmentSelectScreen> {
  String selectedPunishment = '랜덤 벌칙';

  Widget punishmentButton(String title) {
    final selected =
        selectedPunishment == title; //“현재 선택된 벌칙이 이 버튼 제목이랑 같은지 검사해서 결과 저장”

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPunishment = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.14), //선택된버튼이면 흰색, 아니면 반투명
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              title == '랜덤 벌칙'
                  ? Icons.casino
                  : title == '팀장이 직접 선택'
                      ? Icons.person
                      : Icons.edit,
              color: selected ? bgColor : Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: selected ? bgColor : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToTimeSelect() {
    Navigator.push(
      context, //현재 화면 기준으로 새화면 올려라 라는 뜻
      MaterialPageRoute(
        builder: (_) => TimeSelectScreen(
          players: widget.players,
          punishmentType: selectedPunishment,
          selectedGame: widget.selectedGame,
          roomcode: widget.roomcode,
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
        title: const Text('벌칙 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '벌칙을 어떻게 정할까?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                punishmentButton('랜덤 벌칙'),
                punishmentButton('팀장이 직접 선택'),
                punishmentButton('직접 입력'),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ElevatedButton(
                onPressed: goToTimeSelect,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 56),
                  backgroundColor: Colors.white,
                  foregroundColor: bgColor,
                ),
                child: const Text('다음'),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: ChatBox(
                roomcode: widget.roomcode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 시간 선택 화면
class TimeSelectScreen extends StatefulWidget {
  final List<String> players;
  final String punishmentType;
  final String selectedGame;
  final String roomcode;

  const TimeSelectScreen({
    super.key,
    required this.players,
    required this.punishmentType,
    required this.selectedGame,
    required this.roomcode,
  });

  @override
  State<TimeSelectScreen> createState() => _TimeSelectScreenState();
}

class _TimeSelectScreenState extends State<TimeSelectScreen> {
  int selectedTime = 30;

  Widget timeButton(int seconds) {
    final selected = selectedTime == seconds;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTime = seconds;
        });
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(90, 50),
        backgroundColor: selected ? Colors.white : Colors.white24,
        foregroundColor: selected ? bgColor : Colors.white,
      ),
      child: Text('$seconds초'),
    );
  }

  Future<void> startGame() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .update({
      'gameStarted': true,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (widget.selectedGame == '틀린말찾기') {
            return WrongWordGameScreen(
              gameTime: selectedTime,
              players: widget.players,
              punishmentType: widget.punishmentType,
            );
          }
          if (widget.selectedGame == '리듬게임') {
            return RhythmGameScreen(
              gameTime: selectedTime,
              players: widget.players,
              punishmentType: widget.punishmentType,
            );
          }
          if (widget.selectedGame == '초록칸누르기') {
            return GreenTileGameScreen(
              gameTime: selectedTime,
              players: widget.players,
              punishmentType: widget.punishmentType,
            );
          }
          if (widget.selectedGame == '그림맞추기') {
            return PictureCategoryScreen(
              gameTime: selectedTime,
              players: widget.players,
              punishmentType: widget.punishmentType,
            );
          }

          return TapGameScreen(
            gameTime: selectedTime,
            players: widget.players,
            punishmentType: widget.punishmentType,
          );
        },
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
          title: const Text('시간 선택'),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '몇 초 동안 할까?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      timeButton(15),
                      const SizedBox(width: 12),
                      timeButton(30),
                      const SizedBox(width: 12),
                      timeButton(60),
                    ],
                  ),
                  const SizedBox(height: 45),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 60),
                      backgroundColor: Colors.white,
                      foregroundColor: bgColor,
                    ),
                    child: const Text('게임 시작', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: ChatBox(roomcode: widget.roomcode),
            ),
          ],
        ));
  }
}

class WaitingRoomScreen extends StatelessWidget {
  final String roomcode;

  const WaitingRoomScreen({
    super.key,
    required this.roomcode,
  });

  Widget getGameScreen(String selectedGame, List<String> players) {
    if (selectedGame == '틀린말찾기') {
      return WrongWordGameScreen(
        gameTime: 30,
        players: players,
        punishmentType: '랜덤 벌칙',
      );
    }

    if (selectedGame == '리듬게임') {
      return RhythmGameScreen(
        gameTime: 30,
        players: players,
        punishmentType: '랜덤 벌칙',
      );
    }

    if (selectedGame == '초록칸누르기') {
      return GreenTileGameScreen(
        gameTime: 30,
        players: players,
        punishmentType: '랜덤 벌칙',
      );
    }

    if (selectedGame == '그림맞추기') {
      return PictureCategoryScreen(
        gameTime: 30,
        players: players,
        punishmentType: '랜덤 벌칙',
      );
    }

    return TapGameScreen(
      gameTime: 30,
      players: players,
      punishmentType: '랜덤 벌칙',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: Text('대기실 $roomcode'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        //streambuilder가 실시간으로 화면을 그릴 준비를 하고 있다가
        //stream에서 새 데이터가 오면 build()를 다시 실행함
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomcode)
            .snapshots(), //= "계속" 감시해 ; 멀티플레이게임만들때 꼭필요함
        builder: (context, snapshot) {
          //데이터가 없니?
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } //긍까 참가자 입장 감시,게임 선택 감시,게임 시작 감시,
          //방장 변경 감시,Ready 상태 감시를 한번에 하고있는거임

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final players = List<String>.from(data['players'] ?? []);
          final host = data['host'] ?? '';
          final readyPlayers = List<String>.from(data['readyPlayers'] ?? []);
          final allReady = players.every(
            //플레이어 전부 검사
            (player) => readyPlayers.contains(player),
          );

          if (data['gameStarted'] == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final selectedGame = data['selectedGame'] as String;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => getGameScreen(selectedGame, players),
                ),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '참가자 목록',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '방 코드: $roomcode',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: bgColor,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                players[index] == host
                                    ? '👑 ${players[index]}'
                                    : '🙂 ${players[index]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              readyPlayers.contains(players[index])
                                  ? 'READY'
                                  : 'NOT READY',
                              style: TextStyle(
                                color: readyPlayers.contains(players[index])
                                    ? Colors.green
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(roomcode)
                            .update({
                          'readyPlayers': FieldValue.arrayUnion(
                            [players.first],
                          ),
                        });
                      },
                      child: const Text('READY'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      allReady ? '전원 준비 완료!' : '대기 중...',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

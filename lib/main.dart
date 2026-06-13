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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); //HomeScreen 객체 생성 가능하게 해주는 코드

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String myName = '';
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
                  onPressed: () async {
                    if (myName.isEmpty) {
                      await showNicknameDialog();
                    }
                    if (myName.isNotEmpty) {
                      createRoom(context); //context: 현재화면
                    }
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
                    onPressed: () async {
                      myName = '';
                      await showNicknameDialog();
                      if (myName.isNotEmpty) {
                        showJoinRoomDialog(context);
                      }
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
          Positioned(
            left: 16,
            bottom: 16,
            child: ChatBox(
              roomcode: 'global',
              myName: myName,
            ),
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

  Future<void> showNicknameDialog() async {
    final TextEditingController nicknameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('닉네임 입력'),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(
              hintText: '예: 서영',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final nickname = nicknameController.text.trim();

                if (nickname.isNotEmpty) {
                  setState(() {
                    myName = nickname;
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    nicknameController.dispose();
  }

  Future<void> createRoom(BuildContext context) async {
    print("1");
    try {
      final roomcode = makeRoomCode();
      print("2");
      await FirebaseFirestore.instance.collection('rooms').doc(roomcode).set({
        'roomCode': roomcode,
        'players': [myName],
        'host': myName,
        'readyPlayers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'selectedGame': '',
        'gameStarted': false,
        'roomState': 'waiting',
      });
      print("3");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingRoomScreen(
            roomcode: roomcode,
            myName: myName,
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
                    'players': FieldValue.arrayUnion([myName]),
                  });
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WaitingRoomScreen(
                        roomcode: roomcode,
                        myName: myName,
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
  final String myName;

  const GroupSetupScreen({
    super.key,
    required this.roomcode,
    required this.myName,
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
          myName: widget.myName,
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
            child: ChatBox(
              roomcode: widget.roomcode,
              myName: widget.myName,
            ),
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
  final String myName;

  const GameSelectScreen({
    super.key,
    required this.players,
    required this.roomcode,
    required this.myName,
  }); //required : 이 값 반드시 넣어야함

  @override
  State<GameSelectScreen> createState() =>
      _GameSelectScreenState(); //GameSelectedScreen의 상태는 _GameSelectScreenState가 담당한다
} // _ 가 앞에 붙는 이유는 이 파일 내부에서만 사용 가능(private) 이라는 Dart 문법 ! 외부에서 막 쓰지말라는 뜻

class _GameSelectScreenState extends State<GameSelectScreen> {
  Future<void> goToPunishmentSelect(String selectedGame) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .update({
      'selectedGame': selectedGame,
      'roomState': 'punishment_select',
    });
  }

  Widget gameButton(
    String gameName,
    String selectedGame,
    bool isHost,
  ) {
    final selected = selectedGame == gameName;

    return GestureDetector(
      onTap: isHost
          ? () async {
              await FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(widget.roomcode)
                  .update({
                'selectedGame': gameName,
              });
            }
          : null,
      child: Opacity(
        opacity: isHost
            ? 1.0
            : selected
                ? 1.0
                : 0.5,
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
                gameName == '연타게임'
                    ? '👆'
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
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomcode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final host = data['host'] ?? '';
          final isHost = widget.myName == host;
          final selectedGame = data['selectedGame'] ?? '연타게임';
          final roomState = data['roomState'] ?? 'game_select';

          if (roomState == 'punishment_select') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PunishmentSelectScreen(
                    players: widget.players,
                    selectedGame: selectedGame,
                    roomcode: widget.roomcode,
                    myName: widget.myName,
                  ),
                ),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isHost)
                      const Center(
                        child: Text(
                          '방장이 게임 선택 중...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (!isHost) const SizedBox(height: 24),
                    const SizedBox(height: 30),
                    gameButton('연타게임', selectedGame, isHost),
                    gameButton('리듬게임', selectedGame, isHost),
                    gameButton('틀린말찾기', selectedGame, isHost),
                    gameButton('초록칸누르기', selectedGame, isHost),
                    gameButton('그림맞추기', selectedGame, isHost),
                  ],
                ),
                if (isHost)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ElevatedButton(
                      onPressed: () {
                        goToPunishmentSelect(selectedGame);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 56),
                        backgroundColor: Colors.white,
                        foregroundColor: bgColor,
                      ),
                      child: const Text('다음'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 벌칙 설정 화면
class PunishmentSelectScreen extends StatefulWidget {
  final List<String> players; //final: 실행중에결정되어 그뒤로 못바꾸는문법
  final String selectedGame;
  final String roomcode;
  final String myName;
  const PunishmentSelectScreen({
    super.key,
    required this.players,
    required this.selectedGame,
    required this.roomcode,
    required this.myName,
  });

  @override
  State<PunishmentSelectScreen> createState() => _PunishmentSelectScreenState();
}

class _PunishmentSelectScreenState extends State<PunishmentSelectScreen> {
  String selectedPunishment = '랜덤 벌칙';

  Widget punishmentButton(
    String title,
    String punishmentType,
  ) {
    final selected =
        punishmentType == title; //“현재 선택된 벌칙이 이 버튼 제목이랑 같은지 검사해서 결과 저장”

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedPunishment = title;
        });

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomcode)
            .update({
          'punishmentType': title,
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

  Future<void> goToTimeSelect() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .update({
      'punishmentType': selectedPunishment,
      'roomState': 'time_select',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('벌칙 설정'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomcode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final punishmentType = data['punishmentType'] ?? selectedPunishment;
          final roomState = data['roomState'] ?? 'punishment_select';

          if (roomState == 'time_select') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TimeSelectScreen(
                    players: widget.players,
                    punishmentType: punishmentType,
                    selectedGame: widget.selectedGame,
                    roomcode: widget.roomcode,
                    myName: widget.myName,
                  ),
                ),
              );
            });
          }

          return Padding(
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
                    punishmentButton(
                      '랜덤 벌칙',
                      punishmentType,
                    ),
                    punishmentButton(
                      '팀장이 직접 선택',
                      punishmentType,
                    ),
                    punishmentButton(
                      '직접 입력',
                      punishmentType,
                    ),
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
                    myName: widget.myName,
                  ),
                ),
              ],
            ),
          );
        },
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
  final String myName;

  const TimeSelectScreen({
    super.key,
    required this.players,
    required this.punishmentType,
    required this.selectedGame,
    required this.roomcode,
    required this.myName,
  });

  @override
  State<TimeSelectScreen> createState() => _TimeSelectScreenState();
}

class _TimeSelectScreenState extends State<TimeSelectScreen> {
  int selectedTime = 30;

  Widget timeButton(int seconds) {
    final selected = selectedTime == seconds;

    return ElevatedButton(
      onPressed: () async {
        setState(() {
          selectedTime = seconds;
        });

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomcode)
            .update({
          'gameTime': seconds,
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

  String makeFinalPunishment() {
    final randomPunishments = [
      '음료수 사기',
      '편의점 다녀오기',
      '노래 한 소절 부르기',
      '애교하기',
      '다음 판 방장하기',
      '골라준 사진으로 프로필사진 변경하기',
    ];

    if (widget.punishmentType == '랜덤 벌칙') {
      return randomPunishments[Random().nextInt(randomPunishments.length)];
    }

    if (widget.punishmentType == '팀장이 직접 선택') {
      return '팀장이 고른 벌칙';
    }

    return '직접 입력한 벌칙';
  }

  Future<void> startGame() async {
    final finalPunishment = makeFinalPunishment();

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomcode)
        .update({
      'gameTime': selectedTime,
      'gameStarted': true,
      'roomState': 'playing',
      'finalPunishment': finalPunishment,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('시간 선택'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomcode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final selectedTimeFromServer = data['gameTime'] ?? selectedTime;
          final gameStarted = data['gameStarted'] ?? false;

          if (gameStarted == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    if (widget.selectedGame == '틀린말찾기') {
                      return WrongWordGameScreen(
                        gameTime: selectedTimeFromServer,
                        players: widget.players,
                        punishmentType: widget.punishmentType,
                      );
                    }

                    if (widget.selectedGame == '리듬게임') {
                      return RhythmGameScreen(
                        gameTime: selectedTimeFromServer,
                        players: widget.players,
                        punishmentType: widget.punishmentType,
                      );
                    }

                    if (widget.selectedGame == '초록칸누르기') {
                      return GreenTileGameScreen(
                        gameTime: selectedTimeFromServer,
                        players: widget.players,
                        punishmentType: widget.punishmentType,
                      );
                    }

                    if (widget.selectedGame == '그림맞추기') {
                      return PictureCategoryScreen(
                        gameTime: selectedTimeFromServer,
                        players: widget.players,
                        punishmentType: widget.punishmentType,
                      );
                    }

                    return TapGameScreen(
                      gameTime: selectedTimeFromServer,
                      players: widget.players,
                      punishmentType: widget.punishmentType,
                      roomcode: widget.roomcode,
                      myName: widget.myName,
                    );
                  },
                ),
              );
            });
          }

          return Stack(
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
                      child: const Text(
                        '게임 시작',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: ChatBox(
                  roomcode: widget.roomcode,
                  myName: widget.myName,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WaitingRoomScreen extends StatelessWidget {
  final String roomcode;
  final String myName;

  const WaitingRoomScreen({
    super.key,
    required this.roomcode,
    required this.myName,
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
      roomcode: roomcode,
      myName: myName,
    );
  }

  Future<void> leaveRoom(BuildContext context) async {
    final roomRef =
        FirebaseFirestore.instance.collection('rooms').doc(roomcode);

    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      Navigator.pop(context);
      return;
    }

    final data = roomDoc.data() as Map<String, dynamic>;

    final players = List<String>.from(data['players'] ?? []);
    final host = data['host'] ?? '';

    final remainingPlayers =
        players.where((player) => player != myName).toList();

    if (remainingPlayers.isEmpty) {
      await roomRef.delete();
    } else {
      await roomRef.update({
        'players': remainingPlayers,
        'readyPlayers': FieldValue.arrayRemove([myName]),
        'host': host == myName ? remainingPlayers.first : host,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: Text('대기실 $roomcode'),
        automaticallyImplyLeading: false,
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
          final isHost = myName == host;
          final allReady = players.every(
            //플레이어 전부 검사
            (player) => readyPlayers.contains(player),
          );
          final roomState = data['roomState'] ?? 'waiting';

          if (roomState == 'game_select') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // execute {...} after current Frame has been rendered.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameSelectScreen(
                    players: players,
                    roomcode: roomcode,
                    myName: myName,
                  ),
                ),
              );
            });
          } // click 방장 button -> roomState = game_select -> detecting everyone's StreamBuilder -> everyone move to GameSelectScreen

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

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
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
                    Center(
                      child: Column(
                        children: [
                          Text(
                            allReady ? '전원 준비 완료!' : '대기 중...',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (isHost)
                            ElevatedButton(
                              onPressed: allReady
                                  ? () async {
                                      //we dont have to call Navigator.push ourselves
                                      await FirebaseFirestore
                                          .instance //when firestore changes, streambuilder detects it and moves all automatically
                                          .collection('rooms')
                                          .doc(roomcode)
                                          .update({
                                        'roomState': 'game_select',
                                      });
                                    }
                                  : null,
                              child: const Text('게임 선택하러 가기'),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final isReady = readyPlayers.contains(myName);

                    await FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(roomcode)
                        .update({
                      'readyPlayers': isReady
                          ? FieldValue.arrayRemove([myName])
                          : FieldValue.arrayUnion([myName]),
                    });
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    readyPlayers.contains(myName) ? 'CANCEL' : 'READY',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 55),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: ElevatedButton.icon(
                  onPressed: () {
                    leaveRoom(context);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('나가기'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: bgColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

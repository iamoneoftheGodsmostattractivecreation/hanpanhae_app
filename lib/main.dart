import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp()); //앱 시작하면 MyApp 화면 실행하라

const bgColor = Color(0xFF0D1B4C);

class PlayerResult {
  final String name;
  final int score;

  PlayerResult(this.name, this.score);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //MyApp 객체 생성 가능하게해주는코드

  @override //부모 클래스 함수를 재정의한다
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
  void goToGroupSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GroupSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center( //실제 화면 내용물들을 중앙에 배치해라
        child: Column( //세로로 쌓아라: 텍스트,버튼,버튼
          mainAxisAlignment: MainAxisAlignment.center, //세로 방향 기준 가운데 정렬
          children: [ //Column 안에 들어갈 요소들 목록
            const Text(
              '한판해',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50), //50픽셀 빈 공간 : 즉 한판해 (띄우고) 버튼 만드는 거임
            ElevatedButton( //*입체버튼
              onPressed: () => goToGroupSetup(context), //버튼 눌렀을 때 실행할 동작! 그룹 설정화면으로 이동
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 60),
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
              ),
              child: const Text('방 만들기', style: TextStyle(fontSize: 20)), //버튼 안 내용물들
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, //빈 함수 실행 아직 입장하기 버튼 눌렀을 때 어떻게 할지 안정했음 ㅇㅇ
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 60),
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: const Text('입장하기', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// 그룹 설정 화면 (친구 추가됨, 플레이어목록 변함)
class GroupSetupScreen extends StatefulWidget { //상태변하는화면을 만드는 코드
  const GroupSetupScreen({super.key}); //GroupSetupScreen 객체 생성 가능하게 함

  @override //부모함수재정의
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
  //State<뭐시기> :뭐시기용 상태 클래스, 그래서 저건 GroupSetUpScreen 화면 상태임
  //이 화면의 상태를 만들어라, 실제 상태 관리는 _GroupSetupScreenState가 담당
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
      MaterialPageRoute( //게임 선택 화면으로 이동하는 함수 
        builder: (_) => GameSelectScreen(players: players), //이동할 화면을 생성하고, 현재 players 리스트를 다음 화면으로 넘김
      ),
    );
  }

  @override //부모함수재정의
  Widget build(BuildContext context) {
    return Scaffold( //Scaffold에는 배경, appbar, body 같은 걸 담는다. 
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('그룹 설정'), //그룹 설정이라는 텍스트값을 계속 띄울 수 있게 하려고(고정이니까) const를 쓰는 거임
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), //안쪽여백, 상하좌우 24만큼 띄워라.
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
            Expanded( //"남은 공간을 꽉 채워라"
              child: ListView.builder( 
                itemCount: players.length, //리스트 길이만큼 참가자목록을 화면에 그림
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14), //바깥 여백, 아래쪽만 14만큼 띄워라
                    padding: const EdgeInsets.all(18), //안쪽 여백, 상하좌우 전부 18여백
                    decoration: BoxDecoration( //참가자 정보를 담는 카드박스
                      color: Colors.white.withOpacity(0.14), //흰색인데 투명도 14%
                      borderRadius: BorderRadius.circular(18), //모서리를 18 픽셀만큼 둥글게
                    ),
                    child: Row(
                      children: [
                        CircleAvatar( //“동그란 프로필 UI”
                          backgroundColor: Colors.white, //배경색
                          foregroundColor: bgColor, //안에 들어가는 글자색
                          child: Text('${index + 1}'),
                        ),
                        const SizedBox(width: 16), //가로로 16픽셀 빈 공간 넣기 //[동그라미]      이름      : 이렇게 사이 띄우는 거.
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
              child: const Text('다음', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// 게임 선택 화면
class GameSelectScreen extends StatefulWidget {
  final List<String> players;

  const GameSelectScreen({super.key, required this.players}); //required : 이 값 반드시 넣어야함

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState(); //GameSelectedScreen의 상태는 _GameSelectScreenState가 담당한다
} // _ 가 앞에 붙는 이유는 이 파일 내부에서만 사용 가능(private) 이라는 Dart 문법 ! 외부에서 막 쓰지말라는 뜻

class _GameSelectScreenState extends State<GameSelectScreen> {
  String selectedGame = '연타게임';

  void goToPunishmentSelect() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PunishmentSelectScreen(
        players: widget.players,
        selectedGame: selectedGame,
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
      body: Padding( //위젯이름이 Padding인거임
        padding: const EdgeInsets.all(24), // Padding 위젯의 속성: 안의 내용물을 상하좌우 24만큼 안쪽으로 밀어라
        child: Stack( //겹쳐놓는 화면구조
          children: [
            Column( //세로로 나열하는 문법
              crossAxisAlignment: CrossAxisAlignment.start, //가로축 기준 시작점(왼쪽)으로 정렬하라
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
                gameButton('초록칸누르기')
              ],
            ),
            Positioned( //정확환 위치 지정하는 문법
              right: 0, //오른쪽 끝에 붙여라
              bottom: 0, // 아래끝에 붙여라           결과적으로 오른쪽 아래끝에 버튼 생김!!
              child: ElevatedButton(  //배치할 실제 위젯
                onPressed: goToPunishmentSelect,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 56),
                  backgroundColor: Colors.white,
                  foregroundColor: bgColor,
                ),
                child: const Text('입장'),
              ),
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

  const PunishmentSelectScreen({
  super.key,
  required this.players,
  required this.selectedGame,
 });

  @override
  State<PunishmentSelectScreen> createState() => _PunishmentSelectScreenState();
}

class _PunishmentSelectScreenState extends State<PunishmentSelectScreen> {
  String selectedPunishment = '랜덤 벌칙';

  Widget punishmentButton(String title) {
    final selected = selectedPunishment == title; //“현재 선택된 벌칙이 이 버튼 제목이랑 같은지 검사해서 결과 저장”

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
          color: selected ? Colors.white : Colors.white.withOpacity(0.14), //선택된버튼이면 흰색, 아니면 반투명
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

  const TimeSelectScreen({
  super.key,
  required this.players,
  required this.punishmentType,
  required this.selectedGame,
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

  void startGame() {
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
      body: Center(
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
    );
  }
}

// 연타게임 화면
class TapGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const TapGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<TapGameScreen> createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen> {
  int score = 0;
  late int remainingTime;
  Timer? timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        timer?.cancel();

        setState(() {
          remainingTime = 0;
          isGameOver = true;
        });

        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void increaseScore() {
    if (isGameOver) return;

    setState(() {
      score++;
    });
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
      return PlayerResult(name, random.nextInt(80) + 40);
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
        title: const Text('연타게임'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 20),
            Text(
              '점수: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: increaseScore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 220),
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
              ),
              child: const Text('TAP!', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}

// 결과 화면
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
class RhythmGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const RhythmGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
  });

  @override
  State<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends State<RhythmGameScreen> {
  int score = 0;
  late int remainingTime;

  Timer? gameTimer;
  Timer? patternTimer;

  bool isPlayingPattern = true;
  bool canTap = false;

  int currentBeatIndex = 0;
  int patternStartTime = 0;

  final List<int> pattern = [0, 500, 1000, 1250, 1500];

  final List<int> userTaps = [];

  @override
  void initState() {
    super.initState();
    remainingTime = widget.gameTime;
    startGameTimer();
    playPattern();
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime <= 1) {
        gameTimer?.cancel();
        patternTimer?.cancel();
        goToResultScreen();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void playPattern() {
    setState(() {
      isPlayingPattern = true;
      canTap = false;
      currentBeatIndex = 0;
      userTaps.clear();
    });

    patternStartTime = DateTime.now().millisecondsSinceEpoch;

    for (int beatTime in pattern) {
      Future.delayed(Duration(milliseconds: beatTime), () {
        if (!mounted) return;

        setState(() {
          currentBeatIndex++;
        });
      });
    }

    Future.delayed(
      Duration(milliseconds: pattern.last + 700),
      () {
        if (!mounted) return;

        setState(() {
          isPlayingPattern = false;
          canTap = true;
          currentBeatIndex = 0;
          patternStartTime = DateTime.now().millisecondsSinceEpoch;
        });
      },
    );
  }

  void tapRhythm() {
    if (!canTap) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final tapTime = now - patternStartTime;

    setState(() {
      userTaps.add(tapTime);
      currentBeatIndex++;
    });

    if (userTaps.length == pattern.length) {
      judgePattern();
    }
  }

  void judgePattern() {
    int roundScore = 0;

    for (int i = 0; i < pattern.length; i++) {
      final diff = (userTaps[i] - pattern[i]).abs();

      if (diff <= 180) {
        roundScore += 2;
      } else if (diff <= 300) {
        roundScore += 1;
      } else {
        roundScore -= 1;
      }
    }

    setState(() {
      score += roundScore;
      canTap = false;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      playPattern();
    });
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

      return PlayerResult(name, random.nextInt(20) - 3);
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
    patternTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = isPlayingPattern ? '리듬을 기억해!' : '이제 따라 쳐!';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('리듬게임'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '남은 시간: $remainingTime초',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              '점수: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '박자: $currentBeatIndex / ${pattern.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: tapRhythm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 220),
                shape: const CircleBorder(),
                backgroundColor: canTap ? Colors.white : Colors.white24,
                foregroundColor: bgColor,
              ),
              child: Text(
                canTap ? 'TAP' : 'LISTEN',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class GreenTileGameScreen extends StatefulWidget {
  final int gameTime;
  final List<String> players;
  final String punishmentType;

  const GreenTileGameScreen({
    super.key,
    required this.gameTime,
    required this.players,
    required this.punishmentType,
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
        score--;
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
      } else {
        score--;
      }
    });
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

      return PlayerResult(name, random.nextInt(25) - 5);
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
    tileTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('초록칸게임'),
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
    );
  }
}

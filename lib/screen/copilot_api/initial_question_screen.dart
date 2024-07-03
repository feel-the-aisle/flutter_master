import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:probono_project/layout/touchpad_copilot.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InitialQuestionScreen extends StatefulWidget {
  const InitialQuestionScreen({super.key});

  @override
  _InitialQuestionScreenState createState() => _InitialQuestionScreenState();
}

class _InitialQuestionScreenState extends State<InitialQuestionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _recognizedText = '';
  final FlutterTts tts = FlutterTts();
  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  final TextEditingController con = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/colipot_Receipt.mp3');
      _audioPlayer.setVolume(1.0);
      _audioPlayer.play();
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          // 안내 음성 재생 완료 후 터치패드 기능 활성화
          // 이후 동작은 _updateRecognizedText로 관리
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _updateRecognizedText(String text) {
    setState(() {
      _recognizedText = text;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('조리법 검색하기'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(28.0),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(80.0),
                        ),
                      ),
                      child: Text(
                        '상품명을 말하면 조리법을 찾아드립니다. 다음은 질문의 예시입니다. '
                            '"배홍동 비빔면"조리법 알려줘.',
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(34.0),
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.yellow[300],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(80.0),
                        ),
                      ),
                      child: Text(
                        _recognizedText.isEmpty
                            ? ''
                            : _recognizedText,
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  TextField(
                    controller: con,
                  ),
                  TextButton(
                    onPressed: () => tts.speak(con.text),
                    child: Text("재생버튼"),
                  ),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TouchPad_Copilot(
              onTextRecognized: _updateRecognizedText,
            ),
          ),
        ],
      ),
    );
  }
}

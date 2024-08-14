import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TouchPad_Copilot extends StatefulWidget {
  final Function(String) onTextRecognized;
  final bool awaitingFinalResponse; // 새 매개변수 추가

  const TouchPad_Copilot(
      {Key? key,
        required this.onTextRecognized,
        required this.awaitingFinalResponse,
      }) : super(key: key);

  @override
  _TouchPad_CopilotState createState() => _TouchPad_CopilotState();
}

class _TouchPad_CopilotState extends State<TouchPad_Copilot> {
  final AudioPlayer _effectPlayer = AudioPlayer();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _playMicOnEffect() async {
    try {
      await _effectPlayer.setAsset('assets/audio/microphone_on.mp3');
      _effectPlayer.setVolume(1.0);
      _effectPlayer.play();
    } catch (e) {
      print('Error playing mic on effect: $e');
    }
  }

  Future<void> _playMicOffEffect() async {
    try {
      await _effectPlayer.setAsset('assets/audio/microphone_off.mp3');
      _effectPlayer.setVolume(1.0);
      _effectPlayer.play();
    } catch (e) {
      print('Error playing mic off effect: $e');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done') {
          _startListening();
        }
      },
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            widget.onTextRecognized(val.recognizedWords);
          });
        },
        localeId: 'ko-KR', // 한국어 설정
        listenFor: Duration(hours: 1), // 장시간 녹음 설정
        pauseFor: Duration(seconds: 3), // 자동 일시정지 시간 설정
        cancelOnError: false, // 오류 발생 시 녹음 취소 방지
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      _playMicOffEffect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) {
          _playMicOnEffect();
          _startListening();
        },
        onLongPressEnd: (_) {
          _stopListening();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            color: Colors.amberAccent,
            width: 412,
            height: 435,
            child: Center(
              child: Text(
                "터치패드",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

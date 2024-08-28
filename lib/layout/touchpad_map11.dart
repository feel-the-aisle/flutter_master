import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TouchPad_Map11 extends StatefulWidget {
  final Function(bool) onConfirmation;
  final Function(String) onTextRecognized;
  final bool isConfirming;

  const TouchPad_Map11({
    Key? key,
    required this.onConfirmation,
    required this.onTextRecognized,
    required this.isConfirming,
  }) : super(key: key);

  @override
  _TouchPad_Map1State createState() => _TouchPad_Map1State();
}

class _TouchPad_Map1State extends State<TouchPad_Map11> {
  final AudioPlayer _effectPlayer = AudioPlayer();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Color _padColor = Colors.amberAccent;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _playEffect(String asset) async {
    try {
      await _effectPlayer.setAsset(asset);
      await _effectPlayer.setVolume(1.0);
      await _effectPlayer.play();
    } catch (e) {
      print('Error playing effect: $e');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          _stopListening();
        }
      },
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() {
        _isListening = true;
        _padColor = Colors.orangeAccent;  // 터치패드 색상 변경
      });
      await _playEffect('assets/audio/microphone_on.mp3');
      _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            widget.onTextRecognized(val.recognizedWords);
            _stopListening();
          }
        },
        localeId: 'ko-KR',
        listenFor: Duration(hours: 1),
        pauseFor: Duration(seconds: 3),
        cancelOnError: false,
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _padColor = Color(0xFFFFFF00);  // 터치패드 색상 복원
      });
      _playEffect('assets/audio/microphone_off.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) {
          if (!widget.isConfirming) {
            _startListening();
          }
        },
        onLongPressEnd: (_) {
          if (!widget.isConfirming) {
            _stopListening();
          }
        },
        onTap: () {
          if (widget.isConfirming) {
            _playEffect('assets/audio/single_tap.mp3');
            widget.onConfirmation(true);
          }
        },
        onDoubleTap: () {
          if (widget.isConfirming) {
            _playEffect('assets/audio/double_tap.mp3');
            widget.onConfirmation(false);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            color: _padColor,
            width: 412,
            height: 435,
            child: Center(
              child: Text(
                "터치패드",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0000FF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

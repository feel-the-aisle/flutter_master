import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:probono_project/layout/touchpad_map1.dart';
import 'package:probono_project/screen/food_map/final_map.dart';

class GetEndShelf extends StatefulWidget {
  final String storeName;
  final String startShelf;

  const GetEndShelf({super.key, required this.storeName, required this.startShelf});

  @override
  _GetEndShelfState createState() => _GetEndShelfState();
}

class _GetEndShelfState extends State<GetEndShelf> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _endShelf = ''; // 목적지 진열대 이름 변수
  String _confirmationText = ''; //확인 문구 담기는 변수
  String _finalResponse = ''; // 예,아니오 결과를 담는 변수
  final FlutterTts tts = FlutterTts();
  String language = "ko-KR"; //tts:한국어로 설정
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  bool _isConfirming = false;
  bool _awaitingFinalResponse = false;

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/sayEndShelf.mp3');
      _audioPlayer.setVolume(1.0);
      _audioPlayer.play();
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          // 안내 음성 재생 완료 후 터치패드 기능 활성화
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _updateRecognizedText(String text) {
    setState(() {
      _endShelf = text;
      _isConfirming = true;
      _confirmationText = '$text이 맞습니까? 맞으면 맞습니다, 다시 녹음을 원하면 아닙니다를 말씀하세요.';
      _speak(_confirmationText);
      _awaitingFinalResponse = true;
    });
  }

  void _updateFinalResponse(String text) {
    setState(() {
      _finalResponse = text;
      _awaitingFinalResponse = false;
      _handleConfirmation(text);
    });
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage(language);
    await tts.setVoice(voice);
    await tts.setSpeechRate(rate);
    await tts.setVolume(volume);
    await tts.setPitch(pitch);
    await tts.speak(text);
  }

  void _handleConfirmation(String text) async {
    if (text.toLowerCase() == '맞습니다') {
      await Future.delayed(Duration(seconds: 1)); // 1초 지연
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalMap(
            storeName: widget.storeName,
            startShelf: widget.startShelf,
            endShelf: _endShelf,
          ),
        ),
      );
    } else if (text.toLowerCase() == '아닙니다') {
      await Future.delayed(Duration(seconds: 1)); // 1초 지연
      setState(() {
        _endShelf = '';
        _confirmationText = '';
        _finalResponse = '';
        _isConfirming = false;
        _awaitingFinalResponse = false;
        _playAudio();
      });
    }
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
        title: Text('최종 진열대 경로찾기'),
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
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(80.0),
                        ),
                      ),
                      child: Text(
                        '목적지 진열대를 말씀해주세요!',
                        style: TextStyle(
                          fontSize: 27.0,
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
                        _endShelf.isEmpty ? '' : _endShelf,
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  if (_isConfirming)
                    Column(
                      children: [
                        SizedBox(height: 40.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(28.0),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(80.0),
                              ),
                            ),
                            child: Text(
                              _confirmationText,
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
                              _finalResponse.isEmpty ? '' : _finalResponse,
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TouchPad_Map1(
              onTextRecognized: _awaitingFinalResponse
                  ? _updateFinalResponse
                  : _updateRecognizedText,
              awaitingFinalResponse: _awaitingFinalResponse,
            ),
          ),
        ],
      ),
    );
  }
}

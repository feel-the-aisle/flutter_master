import 'package:flutter/material.dart';
import 'package:probono_project/layout/touchpad_map11.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InitialQuestionScreen extends StatefulWidget {
  const InitialQuestionScreen({super.key});

  @override
  _InitialQuestionScreenState createState() => _InitialQuestionScreenState();
}

class _InitialQuestionScreenState extends State<InitialQuestionScreen> {
  String _ramenName = ''; // 라면 이름 변수
  String _confirmationText = ''; // 확인 문구 담기는 변수
  String _finalResponse = ''; // 예, 아니오 결과를 담는 변수
  String _recipe = ''; // 서버로부터 받은 조리법을 저장하는 변수
  final FlutterTts tts = FlutterTts();
  String language = "ko-KR"; // tts: 한국어로 설정
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _speak("상품명을 말하면 조리법을 찾아드립니다!");
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage(language);
    await tts.setVoice(voice);
    await tts.setSpeechRate(rate);
    await tts.setVolume(volume);
    await tts.setPitch(pitch);
    await tts.speak(text);
  }

  void _updateRecognizedText(String text) {
    setState(() {
      _ramenName = text;
      _isConfirming = true;
      _confirmationText = '$text이 맞습니까? 터치패드를 한 번 누르면 맞습니다, 두 번 누르면 아닙니다.';
      _speak(_confirmationText);
    });
  }

  void _handleConfirmation(bool isConfirmed) async {
    if (isConfirmed) {
      setState(() {
        _finalResponse = "맞습니다";
      });

      final response = await _sendRamenNameToServer(_ramenName);
      setState(() {
        _recipe = response ?? '조리법을 가져오는 데 실패했습니다.';
        _isConfirming = false;
      });

      // 조리법을 읽어주기
      _speak(_recipe);
    } else {
      await Future.delayed(Duration(seconds: 1)); // 1초 지연
      setState(() {
        _ramenName = '';
        _confirmationText = '';
        _finalResponse = '';
        _recipe = '';
        _isConfirming = false;
        _speak("상품명을 말하면 조리법을 찾아드립니다!");
      });
    }
  }

  Future<String?> _sendRamenNameToServer(String ramenName) async {
    final url = Uri.parse('http://3.37.101.243:8080/gpt-ramen/recipes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'request_ramen': ramenName}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final recipe = data['recipe'] as String;
      return recipe;
    } else {
      print('Failed to load recipe with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  @override
  void dispose() {
    tts.stop(); // TTS 중지
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
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(80.0),
                        ),
                      ),
                      child: Text(
                        '상품명을 말하면 조리법을 찾아드립니다!',
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
                        _ramenName.isEmpty ? '' : _ramenName,
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
                  if (_recipe.isNotEmpty)
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
                              _recipe,
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TouchPad_Map11(
              onConfirmation: _handleConfirmation,
              onTextRecognized: _updateRecognizedText,
              isConfirming: _isConfirming,
            ),
          ),
        ],
      ),
    );
  }
}

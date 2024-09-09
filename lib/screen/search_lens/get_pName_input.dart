import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:probono_project/screen/search_lens/product_cam1.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../layout/touchpad_map11.dart';

class GetpNameCam extends StatefulWidget {
  const GetpNameCam({super.key});

  @override
  _GetpNameCamState createState() => _GetpNameCamState();
}

class _GetpNameCamState extends State<GetpNameCam> {
  final FlutterTts tts = FlutterTts();
  late IO.Socket _socket;

  String _productName = ''; // 상품 이름 변수
  String _confirmationText = ''; // 확인 문구 담기는 변수
  String language = "ko-KR"; // tts: 한국어로 설정
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  bool _isConfirming = false; // 상품 이름 입력 후 확인 단계 표시

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _speak("찾을 상품의 이름을 말씀해주세요!");
  }

  void _initializeSocket() {
    _socket = IO.io(
      'http://15.165.246.238:8080',
      IO.OptionBuilder()
          .setTransports(['websocket']) // 웹소켓만 사용
          .disableAutoConnect() // 자동 연결 비활성화
          .build(),
    );

    _socket.connect(); // 소켓 연결

    _socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    _socket.onConnectError((error) {
      print('Connection Error: $error');
    });

    _socket.onError((error) {
      print('Error: $error');
    });

    _socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  void _sendProductName(String productName) {
    // 서버에 "request_class" 이벤트로 메시지 전송
    _socket.emit('product_name', {'product_name': productName});
    print('Sent product_name: $productName');
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
      _productName = text;
      _isConfirming = true;
      _confirmationText = '$text이 맞습니까? 터치패드를 한 번 누르면 맞습니다, 두 번 누르면 아닙니다.';
      _speak(_confirmationText);
    });
  }

  void _handleConfirmation(bool isConfirmed) async {
    if (isConfirmed) {
      // 소켓을 통해 _productName 값을 백엔드로 전송
      _sendProductName(_productName);

      await Future.delayed(Duration(seconds: 1)); // 1초 지연
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductCam1(productName: _productName), // Pass the product name here
        ),
      );
    } else {
      await Future.delayed(Duration(seconds: 1)); // 1초 지연
      setState(() {
        _productName = '';
        _confirmationText = '';
        _isConfirming = false;
        _speak("찾을 상품의 이름을 말씀해주세요!");
      });
    }
  }

  @override
  void dispose() {
    _socket.dispose(); // 소켓 연결 해제
    tts.stop(); // TTS 중지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 구별하기'),
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
                        '찾을 상품의 이름을 말씀해주세요!',
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
                        _productName.isEmpty ? '' : _productName,
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
                      ],
                    ),
                  SizedBox(height: 40.0),
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

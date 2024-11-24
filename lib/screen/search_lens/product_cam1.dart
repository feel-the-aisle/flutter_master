import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:probono_project/layout/touchpad_cam.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class ProductCam1 extends StatefulWidget {
  final String productName;
  ProductCam1({required this.productName});

  @override
  _ProductCam1State createState() => _ProductCam1State();
}

class _ProductCam1State extends State<ProductCam1> {
  CameraController? _cameraController;
  String _currentQuadrant = '';
  XFile? _lastCapturedImage; // 마지막으로 촬영된 이미지 저장
  final FlutterTts tts = FlutterTts();
  String language = "ko-KR"; // tts: 한국어로 설정
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    tts.stop(); // TTS 중지
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('가능한 카메라 없음');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController?.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('카메라 초기화 에러: $e');
    }
  }

  // 사진 촬영 메소드
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('카메라 시작 X');
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _lastCapturedImage = photo; // 촬영된 이미지 저장
      });
    } catch (e) {
      print('카메라 캡쳐 오류: $e');
    }
  }

  Future<void> _sendPhotoToServer() async {
    if (_lastCapturedImage == null) {
      print('사용가능한 캡쳐 이미지 없음');
      return;
    }

    try {
      final Uint8List imageBytes = await _lastCapturedImage!.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('http://15.165.246.238:8080/detect-products/detect'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "image": base64Image,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        // 리스트의 첫 번째 객체에서 quadrant 값만 추출
        List<dynamic> detectedObjects = decodedResponse['detected_objects'];
        if (detectedObjects.isNotEmpty) {
          setState(() {
            _currentQuadrant = detectedObjects[0]['quadrant'];
          });
          _speak("상품 '${widget.productName}'의 위치는 진열대 ${_currentQuadrant}입니다.");
        } else {
          setState(() {
            _currentQuadrant = '상품을 찾을 수 없습니다';
          });
        }
      } else {
        print('서버 오류: ${response.statusCode}');
        setState(() {
          _currentQuadrant = '위치 확인 실패';
        });
      }
    } catch (e) {
      print('응답 수신 오류: $e');
      setState(() {
        _currentQuadrant = '오류 발생';
      });
    }
  }

  // TTS로 문장 읽기 메소드
  Future<void> _speak(String text) async {
    await tts.setLanguage(language);
    await tts.setVoice(voice);
    await tts.setSpeechRate(rate);
    await tts.setVolume(volume);
    await tts.setPitch(pitch);
    await tts.speak(text);
  }

  // 터치패드 탭 핸들러
  void _handleTouchpadTap() async {
    await _capturePhoto(); // 먼저 사진 촬영
    await _sendPhotoToServer(); // 그 다음 서버로 전송
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품 구별하기'),
      ),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: MediaQuery.of(context).size.height * 0.65,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.width,
                  height: _cameraController!.value.previewSize!.height,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          Positioned(
            bottom: 270,
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "'${widget.productName}'의 위치는 \n 진열대 ${_currentQuadrant}입니다.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: TouchPad_Cam(
                productName: widget.productName,
                onTap: _handleTouchpadTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
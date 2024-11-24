import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:probono_project/layout/touchpad_cam.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available');
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
      print('Error initializing camera: $e');
    }
  }

  // 사진 촬영 메소드
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera not initialized');
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _lastCapturedImage = photo; // 촬영된 이미지 저장
      });
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  // 서버로 사진 전송 메소드
  Future<void> _sendPhotoToServer() async {
    if (_lastCapturedImage == null) {
      print('No captured image available');
      return;
    }

    try {
      // 이미지를 base64로 인코딩
      final Uint8List imageBytes = await _lastCapturedImage!.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // HTTP POST 요청 보내기
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
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          _currentQuadrant = decodedResponse['quadrant'];
        });
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending photo: $e');
    }
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
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';  // 타이머를 사용하기 위해 추가

class ProductCam1 extends StatefulWidget {
  @override
  _ProductCam1State createState() => _ProductCam1State();
}

class _ProductCam1State extends State<ProductCam1> {
  CameraController? _cameraController;
  late IO.Socket _socket;
  bool _isStreaming = false;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSocket();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _socket.dispose();
    _frameTimer?.cancel();  // 타이머 취소
    super.dispose();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController?.initialize();
    setState(() {});

    _startStreaming();  // 카메라 초기화 후 바로 스트리밍 시작

    _cameraController?.startImageStream((CameraImage image) {
      if (_isStreaming) {
        _scheduleFrameTransmission(image);  // 프레임 전송 예약
      }
    });
  }

  void _initializeSocket() {
    _socket = IO.io('http://15.165.246.238:8080', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket.connect();

    _socket.onConnect((_) {
      print('연결됏따아ㅏ아아아아앙아아아아아아아아아아아아');
    });

    _socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });

    _socket.on('video_response', (data) {
      print('Received response: $data');
    });
  }

  void _scheduleFrameTransmission(CameraImage image) {
    if (_frameTimer?.isActive ?? false) return;  // 타이머가 이미 작동 중이면 반환

    _frameTimer = Timer(Duration(seconds: 3), () {
      _processCameraImage(image);
    });
  }

  void _processCameraImage(CameraImage image) {
    final List<int> yuvBytes = _concatenatePlanes(image.planes);
    final Uint8List imageBytes = Uint8List.fromList(yuvBytes);
    final String base64Image = base64Encode(imageBytes);

    _socket.emit('frame', base64Decode(base64Image));
  }

  List<int> _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void _startStreaming() {
    setState(() {
      _isStreaming = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Camera Stream'),
      ),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
        ],
      ),
    );
  }
}

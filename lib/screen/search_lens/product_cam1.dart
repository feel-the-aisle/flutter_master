import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:probono_project/layout/touchpad_cam.dart';  // Make sure this is the correct path
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class ProductCam1 extends StatefulWidget {
  final String productName;  // Add the productName parameter

  // Update constructor to accept productName
  ProductCam1({required this.productName});

  @override
  _ProductCam1State createState() => _ProductCam1State();
}

class _ProductCam1State extends State<ProductCam1> {
  CameraController? _cameraController;
  late IO.Socket _socket;
  bool _isStreaming = false;
  Timer? _frameTimer;
  String _currentQuadrant = '';  // Quadrant variable

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
    _frameTimer?.cancel();
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

    _startStreaming();

    _cameraController?.startImageStream((CameraImage image) {
      if (_isStreaming) {
        _scheduleFrameTransmission(image);
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
      print('Connected to WebSocket server');
    });

    _socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });

    _socket.on('video_response', (data) {
      print('Received response: $data');
      setState(() {
        _currentQuadrant = _extractQuadrant(data);  // Update the quadrant when data is received
      });
    });
  }

  String _extractQuadrant(dynamic data) {
    List<dynamic> detectedObjects = data['detected_objects'];
    if (detectedObjects.isNotEmpty) {
      return detectedObjects[0]['quadrant'];
    }
    return 'Unknown';
  }

  void _scheduleFrameTransmission(CameraImage image) {
    if (_frameTimer?.isActive ?? false) return;

    _frameTimer = Timer(Duration(seconds: 3), () {
      _processCameraImage(image);
    });
  }

  void _processCameraImage(CameraImage image) {
    final List<int> yuvBytes = _concatenatePlanes(image.planes);
    final Uint8List imageBytes = Uint8List.fromList(yuvBytes);
    final String base64Image = base64Encode(imageBytes);

    print('Frame Width: ${image.width}, Frame Height: ${image.height}');

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

        title: Text('상품 구별하기'),
      ),
      body: Stack(  // Stack allows layering
        children: [
          // Camera Preview (bottom layer)
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: MediaQuery.of(context).size.height * 0.65,  // Adjust the camera height to 60% of the screen
              child: FittedBox(
                fit: BoxFit.cover,  // Cover the entire available space
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.width,
                  height: _cameraController!.value.previewSize!.height,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          // Black SizedBox for displaying product name and quadrant (overlay on the camera preview)
          Positioned(
            bottom: 230,  // Adjust position of the black box
            left: MediaQuery.of(context).size.width * 0.2,  // Adjust the left and right padding to reduce width
            right: MediaQuery.of(context).size.width * 0.2, // Adjust the width
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),  // Black background with transparency
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "'${widget.productName}'의 위치는 \n 진열대 ${_currentQuadrant}입니다.",  // Display productName and quadrant
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,  // Yellow text color
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Touchpad Overlay (on top of the camera preview)
          Positioned(
            bottom: 0,  // Stick to the bottom
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,  // Adjust the height of the touchpad
              child: TouchPad_Cam(productName: widget.productName),  // Pass productName to the touchpad
            ),
          ),
        ],
      ),
    );
  }
}

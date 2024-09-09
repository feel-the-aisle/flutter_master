import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:probono_project/layout/touchpad_cam.dart';  // Make sure this is the correct path
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class ProductCam2 extends StatefulWidget {
  final String productName;  // Add the productName parameter

  // Update constructor to accept productName
  ProductCam2({required this.productName});

  @override
  _ProductCam2State createState() => _ProductCam2State();
}

class _ProductCam2State extends State<ProductCam2> {
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
      body: Stack(
        children: [
          // Camera Preview
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          // Black SizedBox for displaying product name and quadrant
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,  // Adjust position of the box
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,  // Set the height of the black box
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,  // Black background color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "'${widget.productName}'는 진열대 ${_currentQuadrant}에 있습니다.",  // Display productName and quadrant
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,  // Yellow text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // Overlay Touchpad, pass productName to the touchpad widget
          Positioned(
            bottom: 0,  // Position it at the bottom of the screen
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,  // Increase the height of the touchpad
              child: TouchPad_Cam(productName: widget.productName),  // Pass productName to the touchpad
            ),
          ),
        ],
      ),
    );
  }
}

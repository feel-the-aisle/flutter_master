import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProductCam1 extends StatefulWidget {
  @override
  _ProductCamState createState() => _ProductCamState();
}

class _ProductCamState extends State<ProductCam1> {
  late CameraController _controller;
  late IO.Socket _socket;
  bool isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSocket();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {});
  }

  void _initializeSocket() {
    _socket = IO.io('http://<YOUR_FLASK_SERVER_IP>:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('connect', (_) {
      print('Connected to server');
      setState(() {
        isStreaming = true;
      });
      _startStreaming();
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from server');
      setState(() {
        isStreaming = false;
      });
    });
  }

  void _startStreaming() {
    _controller.startImageStream((CameraImage image) {
      if (!isStreaming) return;

      // Convert the image to a format that can be sent over the socket
      final WriteBuffer allBytes = WriteBuffer();
      for (var plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Send the frame data to the server
      _socket.emit('frame', bytes);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Product Camera')),
      body: CameraPreview(_controller),
    );
  }
}

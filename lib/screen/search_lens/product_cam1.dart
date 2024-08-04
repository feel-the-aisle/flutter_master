// lib/product_cam1.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProductCam1 extends StatefulWidget {
  @override
  _ProductCam1State createState() => _ProductCam1State();
}

class _ProductCam1State extends State<ProductCam1> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    // Socket.IO 클라이언트 설정 및 서버와 연결
    _socket = IO.io('http://3.37.101.243:8080', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('connect', (_) {
      print('Connected to server');
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _sendImage() {
    if (_image != null) {
      final bytes = _image!.readAsBytesSync();
      final base64Image = base64Encode(bytes);

      _socket.emit('image', {'image': base64Image});
      print('Image sent to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProductCam1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _sendImage,
              child: Text('Send Image'),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:probono_project/screen/search_lens/product_cam1.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GetProductInput extends StatefulWidget {
  @override
  _GetProductInputState createState() => _GetProductInputState();
}

class _GetProductInputState extends State<GetProductInput> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
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

  void _sendMessage() {
    // 서버에 "request_class" 이벤트로 메시지 전송
    _socket.emit('request_class', {'class_name': 'person'});
  }

  @override
  void dispose() {
    _socket.dispose(); // 소켓 연결 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message to Server'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send "personm 신호" to Server'),
            ),
            SizedBox(height: 20), // 버튼 간격
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProductCam1()),
                );
              },
              child: Text('Go to ProductCam1'),
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: GetProductInput(),
  ));
}

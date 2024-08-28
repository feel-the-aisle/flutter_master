import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FinalMap extends StatefulWidget {
  final String storeName;
  final String startShelf;
  final String endShelf;

  const FinalMap({
    super.key,
    required this.storeName,
    required this.startShelf,
    required this.endShelf,
  });

  @override
  _FinalMapState createState() => _FinalMapState();
}

class _FinalMapState extends State<FinalMap> {
  int rows = 20;
  int columns = 10;
  List<Point> path = [];
  Point startPoint = Point(0, 0);
  Point endPoint = Point(0, 0);
  Point currentPosition = Point(0, 0);
  String endPosition = '';
  List<String> strPath = [];
  final FlutterTts tts = FlutterTts();
  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage(language);
    await tts.setVoice(voice);
    await tts.setSpeechRate(rate);
    await tts.setVolume(volume);
    await tts.setPitch(pitch);
    await tts.speak(text);
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://3.37.101.243:8080/find-path/find_paths');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': widget.storeName,
        'startPoint': widget.startShelf,
        'endPoint': widget.endShelf,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        columns = data['storeGalo'];
        rows = data['storeSelo'];
        path = (data['result'] as List)
            .map((coord) => Point(coord[0], coord[1]))
            .toList();
        startPoint = path.first;
        endPoint = path.last;
        currentPosition = startPoint;
        endPosition = data['endPosition'];
        strPath = List<String>.from(data['strPath']);
      });

      String initialText = '상점명: ${widget.storeName} | 출발 진열대: ${widget.startShelf} | 도착 진열대: ${widget.endShelf}';
      _speak(initialText);
      _speak("경로 설명: ${strPath.join(', ')}");
      _speak('목적지 위치: $endPosition');
    } else {
      throw Exception('Failed to load path data');
    }
  }

  bool isCorrectPath(Point point) {
    return path.contains(point);
  }

  void handleTouch(Point point) {
    if (isCorrectPath(point)) {
      if (Vibration.hasVibrator() != null) {
        Vibration.vibrate();
      }
      setState(() {
        currentPosition = point;
      });
    }
  }

  @override
  void dispose() {
    tts.stop(); // TTS 중지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double blockSize = screenWidth / columns;

    return Scaffold(
      appBar: AppBar(
        title: Text('진열대 경로 찾기'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.storeName}에서 \n ${widget.startShelf}부터 \n ${widget.endShelf}까지 가는 경로입니다.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (path.isEmpty)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Center(
                child: Container(
                  width: blockSize * columns,
                  height: blockSize * rows,
                  color: Colors.grey[300],
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        int newY = (details.localPosition.dy / blockSize).floor();
                        int newX = (details.localPosition.dx / blockSize).floor();
                        Point newPoint = Point(newY, newX);
                        handleTouch(newPoint);
                      });
                    },
                    child: CustomPaint(
                      painter: GridPainter(
                        rows: rows,
                        columns: columns,
                        blockSize: blockSize,
                        currentPosition: currentPosition,
                        startPoint: startPoint,
                        endPoint: endPoint,
                        path: path,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.all(28.0),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${strPath.join(', ')}한 후 $endPosition',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Point {
  final int y;
  final int x;

  Point(this.y, this.x);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Point && runtimeType == other.runtimeType && y == other.y && x == other.x;

  @override
  int get hashCode => y.hashCode ^ x.hashCode;
}

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double blockSize;
  final Point currentPosition;
  final Point startPoint;
  final Point endPoint;
  final List<Point> path;

  GridPainter({
    required this.rows,
    required this.columns,
    required this.blockSize,
    required this.currentPosition,
    required this.startPoint,
    required this.endPoint,
    required this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        Point point = Point(y, x);

        if (point == startPoint) {
          paint.color = Colors.red;
        } else if (point == endPoint) {
          paint.color = Colors.black;
        } else if (path.contains(point)) {
          paint.color = Colors.yellow;
        } else {
          paint.color = Colors.grey;
        }

        if (point == currentPosition) {
          paint.color = Colors.red;
        }

        canvas.drawRect(
          Rect.fromLTWH(
            x * blockSize,
            y * blockSize,
            blockSize - 1,
            blockSize - 1,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../initial_screen/menu.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지

class PaintMapScreen extends StatefulWidget {
  final String storeName;
  final String width;
  final String height;

  PaintMapScreen({required this.storeName, required this.width, required this.height});

  @override
  _PaintMapScreenState createState() => _PaintMapScreenState();
}

class _PaintMapScreenState extends State<PaintMapScreen> {
  List<Color> _blockColors = [];
  Color _selectedColor = Colors.grey;

  // 색상 매핑 정보 (좌표 전송을 위한 숫자 지정)
  final Map<String, Color> colorMap = {
    "라면 진열대": Colors.red,
    "음료 진열대": Colors.yellow,
    "과자 진열대": Colors.blue,
    "기타 진열대": Colors.lightGreen,
    "카운터": Colors.orange,
    "입구": Colors.purple,
    "기타 구조물": Colors.black,
    "기본": Colors.white, // 지우개 역할을 하는 기본 회색
  };

  // 색상과 숫자를 매핑하기 위한 정보
  final Map<Color, int> colorCodeMap = {
    Colors.red: 1,     // 라면 진열대
    Colors.yellow: 2,  // 음료 진열대
    Colors.blue: 3,    // 과자 진열대
    Colors.lightGreen: 4, // 기타 진열대
    Colors.orange: 5,  // 카운터
    Colors.purple: 6,  // 입구
    Colors.black: 7,   // 기타 구조물
  };

  @override
  void initState() {
    super.initState();
    int totalBlocks = int.parse(widget.width) * int.parse(widget.height);
    _blockColors = List<Color>.filled(totalBlocks, colorMap["기본"]!);
  }

  Future<void> _submitData() async {
    List<Map<String, int>> coloredBlocks = [];

    int gridWidth = int.parse(widget.width);
    int gridHeight = int.parse(widget.height);

    for (int i = 0; i < _blockColors.length; i++) {
      Color color = _blockColors[i];
      if (color != colorMap["기본"]) {
        int x = (i % gridWidth);
        int y = (i ~/ gridWidth);
        int colorCode = colorCodeMap[color] ?? 0;

        coloredBlocks.add({"storex": x, "storey": y, "storestate": colorCode});
      }
    }

    Map<String, dynamic> payload = {
      "storename": widget.storeName,
      "storerow": gridHeight,
      "storecol": gridWidth,
      "maps": coloredBlocks,
    };

    // Log the payload
    print("Payload: ${jsonEncode(payload)}");

    try {
      var response = await http.post(
        Uri.parse('http://3.37.101.243:8080/map/store'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 응답: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int gridWidth = int.parse(widget.width);
    int gridHeight = int.parse(widget.height);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.storeName} 지도 그리기', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '실제와 가장 유사하게 등록해주세요!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: _buildGrid(gridWidth, gridHeight),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawingPad(),
        ],
      ),
    );
  }

  Widget _buildGrid(int width, int height) {
    return GridView.builder(
      physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width,
      ),
      itemCount: width * height,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _blockColors[index] = _selectedColor;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Container(
              color: _blockColors[index],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawingPad() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: Colors.grey[350],
        height: MediaQuery.of(context).size.height * 0.33,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorButton("라면 진열대", colorMap["라면 진열대"]!),
                SizedBox(width: 10),
                _colorButton("음료 진열대", colorMap["음료 진열대"]!),
                SizedBox(width: 10),
                _colorButton("과자 진열대", colorMap["과자 진열대"]!),
                SizedBox(width: 10),
                _colorButton("기타 진열대", colorMap["기타 진열대"]!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorButton("입구", colorMap["입구"]!),
                SizedBox(width: 40),
                _colorButton("카운터", colorMap["카운터"]!),
                SizedBox(width: 40),
                _colorButton("기타 구조물", colorMap["기타 구조물"]!),
                SizedBox(width: 40),
                _colorButton("지우개", colorMap["기본"]!),
              ],
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: Text("등록하기", style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(String label, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
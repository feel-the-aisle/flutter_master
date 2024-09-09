import 'package:flutter/material.dart';
import '../initial_screen/menu.dart';
import 'paint_map.dart'; // paint_map.dart 파일을 import

class FirstStore extends StatefulWidget {
  @override
  _FirstStoreState createState() => _FirstStoreState();
}

class _FirstStoreState extends State<FirstStore> {
  final TextEditingController _storeNameController = TextEditingController();
  String? _selectedWidth;
  String? _selectedHeight;
  final List<String> _sizeOptions = List.generate(30, (index) => (index + 1).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('편의점 지도 등록', style: TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()
            ));
            // 뒤로가기 동작 구현
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    '편의점 이름 입력하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _storeNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '편의점 이름을 입력하세요',
                    ),
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(height: 28),
                  Text(
                    '편의점 크기 선택하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      '(한 칸은 약 70cm입니다. 실제와 가장 유사하게 등록해주세요!',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '가로',
                            labelStyle: TextStyle(fontSize: 10),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedWidth,
                          items: _sizeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedWidth = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('X', style: TextStyle(fontSize: 10)),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '세로',
                            labelStyle: TextStyle(fontSize: 10),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedHeight,
                          items: _sizeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedHeight = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        _buildGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 고정된 "다음" 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_storeNameController.text.isNotEmpty &&
                    _selectedWidth != null &&
                    _selectedHeight != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaintMapScreen(
                        storeName: _storeNameController.text,
                        width: _selectedWidth!,
                        height: _selectedHeight!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('모든 필드를 입력해주세요.')),
                  );
                }
              },
              child: Text('다음', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // 노란색 둥근 버튼
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 둥근 모서리 처리
                ),
                padding: EdgeInsets.symmetric(horizontal: 135, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_selectedWidth == null || _selectedHeight == null) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: Center(child: Text('지도', style: TextStyle(fontSize: 12))),
      );
    }

    int width = int.parse(_selectedWidth!);
    int height = int.parse(_selectedHeight!);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: width * height,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../owner/first_store.dart'; // '편의점 점주' 버튼을 누르면 이동할 화면
import '../home_screen/home_screen.dart'; // '시각 장애인' 버튼을 누르면 이동할 화면

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0), // 위아래 패딩 추가
        child: Column(
          children: [
            // 상단 회색 버튼
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FirstStore()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0), // 내부 패딩 추가
                      child: Align(
                        alignment: Alignment.topLeft, // 글씨를 왼쪽 위에 배치
                        child: Text(
                          '편의점 점주',
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.0), // 간격 추가
            // 하단 노란색 버튼
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(80.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // 내부 패딩 추가
                      child: Align(
                        alignment: Alignment.bottomRight, // 글씨를 오른쪽 아래에 배치
                        child: Text(
                          '시각 장애인',
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// file path: lib/screen/food_map/final_map.dart

import 'package:flutter/material.dart';

class FinalMap extends StatelessWidget {
  final String storeName;
  final String startShelf;
  final String endShelf;

  const FinalMap({super.key, required this.storeName, required this.startShelf, required this.endShelf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('최종 경로'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '편의점 이름: $storeName',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              '출발 진열대: $startShelf',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              '목적지 진열대: $endShelf',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

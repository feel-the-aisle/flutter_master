import 'package:flutter/material.dart';

class GetStartShelf extends StatelessWidget {
  final String storeName;
  const GetStartShelf({Key? key, required this.storeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('시작할 지점 말하기'),
      ),
      body: Center(
        child: Text(
          'food',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

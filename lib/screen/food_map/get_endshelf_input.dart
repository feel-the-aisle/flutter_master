import 'package:flutter/material.dart';

class GetEndShelf extends StatelessWidget {
  const GetEndShelf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도착할 지점 말하기'),
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

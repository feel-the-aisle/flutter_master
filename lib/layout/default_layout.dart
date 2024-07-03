import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final List<Widget> children; //쓸 위치에서 커스터마이징해서 쓰도록

  const DefaultButton({
    required this.children,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children, //children은 해당 사용 위치에서 변동적으로 사용하도록 함
        ),
      ),
    );
  }
}

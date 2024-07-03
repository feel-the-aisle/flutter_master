import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center, //중앙 배치
          children: [
            Image.asset(
              'asset/img/logo.png',
            ),
            CircularProgressIndicator(
                color: Colors.amber
            ), //로딩 동그라미
          ],
        )
    );
  }
}

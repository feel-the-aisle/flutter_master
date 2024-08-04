import 'package:flutter/material.dart';
import 'package:probono_project/screen/food_map/find_food/get_store_input.dart';
import 'package:probono_project/screen/copilot_api/initial_question_screen.dart';
import 'package:probono_project/screen/search_lens/get_product_input.dart';

class TouchPadScreen2 extends StatefulWidget {
  @override
  _TouchPadScreenState createState() => _TouchPadScreenState();
}

class _TouchPadScreenState extends State<TouchPadScreen2> {
  int tapCount = 0;
  DateTime? lastTap;

  void handleTap() {
    final now = DateTime.now();
    // 탭 간의 시간 간격을 500ms로 설정합니다.
    if (lastTap == null || now.difference(lastTap!) > Duration(milliseconds: 800)) {
      tapCount = 0;
    }
    tapCount++;
    lastTap = now;

    // 사용자가 추가로 탭을 하지 않을 경우를 대비하여 500ms 후에 탭 카운트를 체크합니다.
    Future.delayed(Duration(milliseconds: 800), () {
      if (tapCount == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => GetStoreInput(),
          ),
        );
      } else if (tapCount == 2) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => GetProductInput(),
          ),
        );
      } else if (tapCount == 3) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => InitialQuestionScreen(),
          ),
        );
      }
      // 탭 카운트를 리셋합니다.
      tapCount = 0;
    });
  }

  void handleLongPress() {
    print("Long press activated, initiate voice recognition");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: handleTap,
        onLongPress: handleLongPress,
        child: Container(
          color: Colors.amberAccent,
          width: 412,
          height: 435,
          child: Center(child: Text("터치패드",
            style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w500,
                color: Colors.black
            ),
          ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:probono_project/layout/default_layout.dart';
import 'package:probono_project/main.dart';
import 'package:probono_project/screen/copilot_api/initial_question_screen.dart';
import 'package:probono_project/screen/food_map/find_food/get_store_input.dart';
import 'package:probono_project/screen/home_screen/home_screen.dart';
import 'package:probono_project/screen/initial_screen/loading_screen.dart';
import 'package:probono_project/screen/search_lens/get_product_input.dart';
import 'package:probono_project/layout/touchpad_main.dart';
import 'package:probono_project/screen/search_lens/product_cam1.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,  // 상단 버튼 영역과 하단 터치패드 영역의 비율을 1:1로 설정
            child: DefaultButton(   // DefaultButton이라고 가정
              children: <Widget>[
                SizedBox(
                  width: 10,
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 80),
                ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => GetStoreInput()));
                  },
                  child: Text('진열대 경로 찾기',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                  ),
                  ),
                ),
                SizedBox(
                  width: 10,
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductCam1()));
                  },
                  child: Text('상품 구별하기',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                  ),
                  ),
                ),
                SizedBox(
                  width: 10,
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => InitialQuestionScreen()));
                  },
                  child: Text('조리법 검색하기',
                      style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                  ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,  // 터치패드가 두 배의 공간을 차지하도록 설정한다
            child: TouchPadScreen(),  // TouchPadScreen 위젯을 불러와서 사용한다
          ),
        ],
      ),
    );
  }
}
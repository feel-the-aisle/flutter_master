import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductCam1(),
    );
  }
}

class ProductCam1 extends StatefulWidget {
  @override
  _ProductCam1State createState() => _ProductCam1State();
}

class _ProductCam1State extends State<ProductCam1> {
  final int rows = 20;
  final int columns = 10;
  final Point startPoint = Point(19, 0); // (20,1) corresponds to (19,0)
  final Point endPoint = Point(17, 2); // (18,3) corresponds to (17,2)
  final List<Point> path = [
    Point(19, 0), // (20,1)
    Point(19, 1), // (20,2)
    Point(19, 2), // (20,3)
    Point(18, 2), // (19,3)
    Point(17, 2), // (18,3)
  ];
  Point currentPosition = Point(19, 0);

  bool isCorrectPath(Point point) {
    return path.contains(point);
  }

  void handleTouch(Point point) {
    if (isCorrectPath(point)) {
      if (Vibration.hasVibrator() != null) {
        Vibration.vibrate();
      }
      setState(() {
        currentPosition = point;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double blockSize = screenWidth / columns;
    double gridHeight = blockSize * rows;
    double maxGridHeight = screenHeight * 0.7; // Leave space for text below

    // Adjust block size to fit the screen height if needed
    if (gridHeight > maxGridHeight) {
      blockSize = maxGridHeight / rows;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('진열대 경로 찾기'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: blockSize * columns,
                height: blockSize * rows,
                color: Colors.grey[300],
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      int newY = (details.localPosition.dy / blockSize).floor();
                      int newX = (details.localPosition.dx / blockSize).floor();
                      Point newPoint = Point(newY, newX);
                      handleTouch(newPoint);
                    });
                  },
                  child: CustomPaint(
                    painter: GridPainter(
                      rows: rows,
                      columns: columns,
                      blockSize: blockSize,
                      currentPosition: currentPosition,
                      startPoint: startPoint,
                      endPoint: endPoint,
                      path: path,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.all(28.0),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width*0.3,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80.0),
                ),
              ),
              child: Text(
                '입구에서 시작해 라면 진열대까지 가는지 방법입니다.\n'
                    '입구에서 10걸음 직진 한 후, 좌회전하여 7걸음 직진하세요. 라면 진열대는 당신의 왼쪽에 있습니다.',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Point {
  final int y;
  final int x;

  Point(this.y, this.x);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Point && runtimeType == other.runtimeType && y == other.y && x == other.x;

  @override
  int get hashCode => y.hashCode ^ x.hashCode;
}

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double blockSize;
  final Point currentPosition;
  final Point startPoint;
  final Point endPoint;
  final List<Point> path;

  GridPainter({
    required this.rows,
    required this.columns,
    required this.blockSize,
    required this.currentPosition,
    required this.startPoint,
    required this.endPoint,
    required this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        Point point = Point(y, x);

        if (point == startPoint) {
          paint.color = Colors.red;
        } else if (point == endPoint) {
          paint.color = Colors.black;
        } else if (path.contains(point)) {
          paint.color = Colors.yellow;
        } else {
          paint.color = Colors.grey;
        }

        if (point == currentPosition) {
          paint.color = Colors.red;
        }

        canvas.drawRect(
          Rect.fromLTWH(
            x * blockSize,
            y * blockSize,
            blockSize - 1,
            blockSize - 1,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

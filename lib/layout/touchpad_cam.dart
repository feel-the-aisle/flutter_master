import 'package:flutter/material.dart';
// Import ProductCam2

class TouchPad_Cam extends StatelessWidget {
  final String productName;  // Accept the productName as a parameter
  final VoidCallback onTap;  // Accept a callback for the tap event

  // Constructor to accept productName and onTap callback
  TouchPad_Cam({required this.productName, required this.onTap});

  // void _navigateToProductCam2(BuildContext context) {
  //   // Navigate to ProductCam2 and pass productName
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ProductCam2(productName: productName),  // Pass productName
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onTap();  // Call the onTap callback to capture and send the photo
        // _navigateToProductCam2(context);  // Navigate to the next screen
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Colors.amberAccent,
          width: double.infinity,
          height: 435,  // You can adjust the height based on your design
          child: Center(
            child: Text(
              "터치패드",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0000FF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
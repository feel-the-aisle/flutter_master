import 'package:flutter/material.dart';
import 'package:probono_project/screen/initial_screen/loading_screen.dart';
import 'package:probono_project/screen/home_screen/home_screen.dart';
import 'package:camera/camera.dart';
import 'dart:async';

import 'package:probono_project/screen/initial_screen/menu.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error: $e');
  }

  runApp(
    MaterialApp(
      title: 'probono',
      home: MenuScreen(),
    ),
  );
}

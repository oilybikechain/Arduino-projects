import 'package:flutter/material.dart';
import 'package:sender_app/hompage.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({
    required this.camera,
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CameraApp',
      home: MyHomePage(camera: camera),
    );
  }
}

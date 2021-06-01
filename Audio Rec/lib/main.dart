import 'package:audio_recording_in_flutter/pages/homePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AudioRec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff0e2546),
        accentColor: Color(0xfffbbec5),
      ),
      home: homePage(),
    );
  }
}

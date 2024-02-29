import 'package:flutter/material.dart';
import 'package:sketch_app/view/drawing_page/drawing_page.dart';

class SketchApp extends StatelessWidget {
  const SketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sketch App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawingPage(),
    );
  }
}

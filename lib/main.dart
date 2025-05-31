import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(MyCalculatorApp());
}

class MyCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData.dark(), // Тёмная тема для чёрного AppBar
      home: CalculatorScreen(),
    );
  }
}

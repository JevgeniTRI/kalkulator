import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Visual Calculator',
debugShowCheckedModeBanner: false,
theme: ThemeData.dark().copyWith(
scaffoldBackgroundColor: Colors.black,
),
home: CalculatorScreen(),
);
}
}

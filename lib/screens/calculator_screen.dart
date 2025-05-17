import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import '../widgets/animated_button.dart';
import '../widgets/display_panel.dart';
import '../db/database_helper.dart';
import '../models/calculation_history.dart';
import 'history_screen.dart';
import 'converter_screen.dart'; // 👈 добавлен импорт

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = '0';
  bool isResult = false;

  final List<List<String>> buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  void onButtonTap(String value) async {
    setState(() {
      if (value == 'C') {
        displayText = '0';
        isResult = false;
      } else if (value == '=') {
        try {
          String expression = displayText.replaceAll('×', '*').replaceAll('÷', '/');
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double result = exp.evaluate(EvaluationType.REAL, cm);

          final formattedResult = result.toString().endsWith('.0')
              ? result.toStringAsFixed(0)
              : result.toString();

          final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          final fullExpression = '$displayText = $formattedResult';

          final entry = CalculationHistory(
            expression: fullExpression,
            timestamp: timestamp,
          );
          DatabaseHelper().insertHistory(entry);

          displayText = formattedResult;
          isResult = true;
        } catch (e) {
          displayText = 'Error';
          isResult = true;
        }
      } else {
        if (isResult || displayText == '0' || displayText == 'Error') {
          displayText = value;
          isResult = false;
        } else {
          displayText += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Visual Calculator'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz, color: Colors.white),
            tooltip: 'Converter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConverterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DisplayPanel(currentText: displayText),
          SizedBox(height: 10),
          ...buttons.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((text) {
                return AnimatedCalcButton(
                  label: text,
                  onTap: () => onButtonTap(text),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }
}

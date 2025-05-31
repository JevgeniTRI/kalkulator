import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import '../widgets/animated_button.dart';
import '../widgets/display_panel.dart';
import '../db/database_helper.dart';
import '../models/calculation_history.dart';
import 'history_screen.dart';
import 'converter_screen.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = '0';
  String currentExpression = '';
  bool justCalculated = false;

  final List<List<String>> buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  bool _isOperator(String val) => ['+', '-', '×', '÷'].contains(val);

  void onButtonTap(String value) async {
    setState(() {
      if (value == 'C') {
        displayText = '0';
        currentExpression = '';
        justCalculated = false;
        return;
      }

      if (value == '=') {
        if (currentExpression.isEmpty) return;

        try {
          final result = _calculate(currentExpression);
          final formatted = _formatResult(result);

          final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          final entry = CalculationHistory(
            expression: '$currentExpression = $formatted',
            timestamp: timestamp,
          );
          DatabaseHelper().insertHistory(entry);

          displayText = formatted;
          currentExpression = formatted;
          justCalculated = true;
        } catch (e) {
          displayText = 'Error';
          currentExpression = '';
          justCalculated = false;
        }
        return;
      }

      if (_isOperator(value)) {
        if (currentExpression.isEmpty && value != '-') return; // только минус в начале
        if (_isOperator(currentExpression.characters.last)) return;

        if (justCalculated) {
          justCalculated = false; // продолжаем от результата
        }
      } else {
        if (justCalculated) {
          // если вводим цифру после =, начинаем заново
          currentExpression = '';
          displayText = '';
          justCalculated = false;
        }
      }

      currentExpression += value;
      displayText = currentExpression;
    });
  }

  double _calculate(String expression) {
    final parsed = expression.replaceAll('×', '*').replaceAll('÷', '/');
    Parser p = Parser();
    Expression exp = p.parse(parsed);
    ContextModel cm = ContextModel();
    return exp.evaluate(EvaluationType.REAL, cm);
  }

  String _formatResult(double result) {
    return result.toString().endsWith('.0')
        ? result.toStringAsFixed(0)
        : result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Visual Calculator'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            tooltip: 'Converter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConverterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
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

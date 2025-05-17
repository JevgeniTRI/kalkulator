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
  bool lastInputWasOperator = false;

  final List<List<String>> buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  bool _isOperator(String val) => ['+', '-', '×', '÷'].contains(val);

  void onButtonTap(String value) async {
    if (value == 'C') {
      setState(() {
        displayText = '0';
        currentExpression = '';
        lastInputWasOperator = false;
      });
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
        await DatabaseHelper().insertHistory(entry);

        setState(() {
          displayText = formatted;
          currentExpression = formatted;
          lastInputWasOperator = false;
        });
      } catch (e) {
        setState(() {
          displayText = 'Error';
          currentExpression = '';
        });
      }
      return;
    }

    setState(() {
      if (_isOperator(value)) {
        if (lastInputWasOperator) return; // запрет подряд операторов
        currentExpression += value;
        displayText = value;
        lastInputWasOperator = true;
      } else {
        if (displayText == '0' || _isOperator(displayText)) {
          displayText = value;
        } else {
          displayText += value;
        }

        currentExpression += value;
        lastInputWasOperator = false;

        // авторасчёт после второго числа
        final tokens = currentExpression.split(RegExp(r'(?<=[×÷+\-])|(?=[×÷+\-])'));
        if (tokens.length >= 3 && _isOperator(tokens[tokens.length - 2])) {
          try {
            final partial = tokens.sublist(0, tokens.length - 1).join('');
            final result = _calculate(partial);
            displayText = _formatResult(result);
            currentExpression = _formatResult(result) + tokens.last;
          } catch (_) {
            // до конца ввода – не мешаем
          }
        }
      }
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

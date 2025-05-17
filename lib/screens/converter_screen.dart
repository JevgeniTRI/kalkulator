import 'package:flutter/material.dart';

class ConverterScreen extends StatefulWidget {
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController controller = TextEditingController();
  String result = '';
  bool milesToKm = true;

  void convert() {
    final input = double.tryParse(controller.text);
    if (input == null) {
      setState(() {
        result = 'Invalid input';
      });
      return;
    }

    double converted = milesToKm ? input * 1.60934 : input / 1.60934;
    setState(() {
      result = '${converted.toStringAsFixed(3)} ${milesToKm ? "km" : "mi"}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Miles ↔ Kilometers'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter value',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  milesToKm ? 'Miles → Kilometers' : 'Kilometers → Miles',
                  style: TextStyle(color: Colors.white),
                ),
                Spacer(),
                Switch(
                  value: milesToKm,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) {
                    setState(() {
                      milesToKm = val;
                      convert();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: convert,
              child: Text('Convert'),
            ),
            SizedBox(height: 24),
            Text(
              result,
              style: TextStyle(color: Colors.amber, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

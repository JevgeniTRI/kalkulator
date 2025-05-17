class CalculationHistory {
  final int? id;
  final String expression;
  final String timestamp;

  CalculationHistory({
    this.id,
    required this.expression,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expression': expression,
      'timestamp': timestamp,
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'],
      expression: map['expression'],
      timestamp: map['timestamp'],
    );
  }
}


import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const IbrahimCalculator());
}

class IbrahimCalculator extends StatelessWidget {
  const IbrahimCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibrahim Smart Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '';
  String result = '0';
  final List<String> history = [];

  final Color blue = const Color(0xFF3987FF);
  final Color panel = const Color(0xFF191F2B);

  void press(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
      } else if (value == 'DEL') {
        if (expression.isNotEmpty) {
          expression =
              expression.substring(0, expression.length - 1);
        }
      } else if (value == '=') {
        calculate();
      } else {
        expression += value;
      }
    });
  }

  void calculate() {
    if (expression.isEmpty) return;
    try {
      final answer = MathParser(expression).parse();
      result = answer.isFinite
          ? (answer.abs() < 1e12
              ? answer.toStringAsPrecision(10)
                  .replaceAll(RegExp(r'\.?0+$'), '')
              : answer.toString())
          : 'خطأ';
      history.insert(0, '$expression = $result');
      if (history.length > 30) history.removeLast();
    } catch (_) {
      result = 'خطأ في العملية';
    }
  }

  Widget button(String label,
      {Color? color, Color? textColor, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => press(label),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: color ?? panel,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: label.length > 4 ? 15 : 21,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget row(List<String> labels) {
    return Row(
      children: labels.map((label) {
        Color? color;
        Color? textColor;

        if (['+', '-', '×', '÷', '^', '='].contains(label)) {
          color = blue;
        } else if ([
          'AC', 'DEL', 'sin(', 'cos(', 'tan(', '√(',
          'log(', 'ln(', 'π', 'e', '(', ')', '%'
        ].contains(label)) {
          color = const Color(0xFF27354B);
          textColor = const Color(0xFF82B5FF);
        }

        return button(label,
            color: color, textColor: textColor);
      }).toList(),
    );
  }

  void showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('سجل العمليات',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text('لا توجد عمليات بعد'))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(history[i],
                              textAlign: TextAlign.right),
                          onTap: () {
                            setState(() {
                              expression =
                                  history[i].split(' = ')[0];
                              result =
                                  history[i].split(' = ').last;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => history.clear());
                  Navigator.pop(context);
                },
                child: const Text('مسح السجل'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Ibrahim Calculator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: showHistory,
            icon: const Icon(Icons.history),
            tooltip: 'سجل العمليات',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('التعبير الحسابي',
                        style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        expression.isEmpty ? '0' : expression,
                        style: const TextStyle(
                            fontSize: 27, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  row(['sin(', 'cos(', 'tan(', '√(']),
                  row(['log(', 'ln(', '^', 'π']),
                  row(['(', ')', '%', 'DEL']),
                  row(['AC', '7', '8', '9']),
                  row(['÷', '4', '5', '6']),
                  row(['×', '1', '2', '3']),
                  row(['-', '0', '.', '=']),
                  row(['+', 'e', '00', '00']),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Ibrahim Smart Calculator',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MathParser {
  final String input;
  int pos = 0;

  MathParser(this.input);

  double parse() {
    final value = expression();
    if (pos != input.length) {
      throw const FormatException('Invalid expression');
    }
    if (!value.isFinite) throw const FormatException('Invalid result');
    return value;
  }

  bool eat(String token) {
    if (input.startsWith(token, pos)) {
      pos += token.length;
      return true;
    }
    return false;
  }

  double expression() {
    double value = term();
    while (pos < input.length) {
      if (eat('+')) {
        value += term();
      } else if (eat('-')) {
        value -= term();
      } else {
        break;
      }
    }
    return value;
  }

  double term() {
    double value = power();
    while (pos < input.length) {
      if (eat('×') || eat('*')) {
        value *= power();
      } else if (eat('÷') || eat('/')) {
        final divisor = power();
        if (divisor == 0) throw const FormatException('Division by zero');
        value /= divisor;
      } else {
        break;
      }
    }
    return value;
  }

  double power() {
    double value = unary();
    if (eat('^')) {
      value = math.pow(value, power()).toDouble();
    }
    return value;
  }

  double unary() {
    if (eat('-')) return -unary();
    if (eat('+')) return unary();
    double value = primary();
    if (eat('%')) value /= 100;
    return value;
  }

  double primary() {
    if (eat('(')) {
      final value = expression();
      if (!eat(')')) throw const FormatException('Missing )');
      return value;
    }

    if (eat('π')) return math.pi;
    if (eat('e')) return math.e;

    for (final fn in ['sin(', 'cos(', 'tan(', '√(', 'log(', 'ln(']) {
      if (eat(fn)) {
        final x = expression();
        if (!eat(')')) throw const FormatException('Missing )');
        switch (fn) {
          case 'sin(':
            return math.sin(x * math.pi / 180);
          case 'cos(':
            return math.cos(x * math.pi / 180);
          case 'tan(':
            return math.tan(x * math.pi / 180);
          case '√(':
            if (x < 0) throw const FormatException('Invalid square root');
            return math.sqrt(x);
          case 'log(':
            if (x <= 0) throw const FormatException('Invalid logarithm');
            return math.log(x) / math.ln10;
          case 'ln(':
            if (x <= 0) throw const FormatException('Invalid logarithm');
            return math.log(x);
        }
      }
    }

    final start = pos;
    while (pos < input.length &&
        RegExp(r'[0-9.]').hasMatch(input[pos])) {
      pos++;
    }
    if (start == pos) throw const FormatException('Number expected');
    return double.parse(input.substring(start, pos));
  }
}
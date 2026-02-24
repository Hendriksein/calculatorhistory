import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'history_screen.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const CalculatorUI(),
        '/converter': (context) => const KilometerToMileConverter(),
      },
    );
  }
}

Future<void> saveToHistory(String expression, String result) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> history = prefs.getStringList('history') ?? [];

  final now = DateTime.now();
  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

  final entry = '$expression = $result\n$formattedDate';

  history.insert(0, entry);

  await prefs.setStringList('history', history);
}



class CalculatorModel {
  double calculate(double num1, double num2, String operator) {
    switch (operator) {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case '*':
        return num1 * num2;
      case '/':
        if (num2 != 0) {
          return num1 / num2;
        } else {
          throw ArgumentError("Nulliga ei saa jagada");
        }
      default:
        throw ArgumentError("Vale operaator");
    }
  }
}



class CalculatorController {
  final CalculatorModel _model = CalculatorModel();
  String _output = "0";
  double? _firstOperand;
  double? _secondOperand;
  String? _operator;

  String get output => _output;

  void input(String value) {
    if (value == 'C') {
      _clear();
    } else if (value == '+' || value == '-' || value == '*' || value == '/') {
      _operator = value;
      _firstOperand = double.tryParse(_output);
      _output = "0";
    } else if (value == '=') {
      if (_firstOperand != null && _operator != null) {
        _secondOperand = double.tryParse(_output);
        if (_secondOperand != null) {
          try {
            double result = _model.calculate(
                _firstOperand!, _secondOperand!, _operator!);

            String expression =
                '${_firstOperand!} $_operator ${_secondOperand!}';

            _output = result.toString();

            saveToHistory(expression, _output);
          } catch (e) {
            _output = "Error";
          }
        }
      }
    } else {
      if (_output == "0") {
        _output = value;
      } else {
        _output += value;
      }
    }
  }

  void _clear() {
    _output = "0";
    _firstOperand = null;
    _secondOperand = null;
    _operator = null;
  }
}



class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  final CalculatorController _controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulaator'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
              child: Text(
                _controller.output,
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Column(
              children: [
                buildButtonRow(['7', '8', '9', '/']),
                buildButtonRow(['4', '5', '6', '*']),
                buildButtonRow(['1', '2', '3', '-']),
                buildButtonRow(['C', '0', '=', '+']),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/converter');
              },
              child: const Text(
                  'Mine kilomeetri miilidesse teisendaja lehele'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((text) => buildButton(text)).toList(),
      ),
    );
  }

  Widget buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _controller.input(text);
            });
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}



class KilometerToMileConverter extends StatefulWidget {
  const KilometerToMileConverter({super.key});

  @override
  State<KilometerToMileConverter> createState() =>
      _KilometerToMileConverterState();
}

class _KilometerToMileConverterState
    extends State<KilometerToMileConverter> {
  final TextEditingController _controller =
  TextEditingController();
  String _result = "";

  void _convert() {
    final double? kilometers =
    double.tryParse(_controller.text);

    if (kilometers != null) {
      final double miles = kilometers * 0.621371;
      setState(() {
        _result =
        "$kilometers km = ${miles.toStringAsFixed(2)} miles";
      });
    } else {
      setState(() {
        _result = "Invalid input";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Kilomeetri miilidesse teisendaja'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sisesta kilomeetrid',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Teisenda miilidesse'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                  'Tagasi kalkulaatori juurde'),
            ),
          ],
        ),
      ),
    );
  }
}
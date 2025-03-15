import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  TextEditingController num1Controller = TextEditingController();
  TextEditingController num2Controller = TextEditingController();

  String selectedOperation = 'Add';
  double result = 0;

  void calculateResult() {
    double num1 = double.tryParse(num1Controller.text) ?? 0;
    double num2 = double.tryParse(num2Controller.text) ?? 0;

    setState(() {
      if (selectedOperation == 'Add') {
        result = num1 + num2;
      } else if (selectedOperation == 'Subtract') {
        result = num1 - num2;
      } else if (selectedOperation == 'Multiply') {
        result = num1 * num2;
      } else if (selectedOperation == 'Divide') {
        result = num2 != 0 ? num1 / num2 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CALCULATOR'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: num1Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter 1st Value',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: num2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter 2nd Value',
                ),
              ),
              const SizedBox(height: 30),
              DropdownButton<String>(
                value: selectedOperation,
                items: const [
                  DropdownMenuItem(value: 'Add', child: Text('Add')),
                  DropdownMenuItem(value: 'Subtract', child: Text('Subtract')),
                  DropdownMenuItem(value: 'Multiply', child: Text('Multiply')),
                  DropdownMenuItem(value: 'Divide', child: Text('Divide')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOperation = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateResult,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 40),
              Text(
                'Your Result: $result',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
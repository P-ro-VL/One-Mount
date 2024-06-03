// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

void main() {
  runApp(Calculator());
}

class CalculatorController extends GetxController {
  var expression = "".obs;

  append(String digit) {
    expression.value += digit;
  }

  clear() {
    expression.value = "";
  }

  calculateResult() {
    var exp = expression.value;

    var result = 0.0;

    var isFunctionTurn = false;
    var lastFunction = "";

    RegExp functionRegex = RegExp(r"\W");
    RegExp numberRegex = RegExp(r"\d+\.\d+");

    while (exp.isNotEmpty) {
      if (!isFunctionTurn) {
        var rawNumber = numberRegex.firstMatch(exp)![0]!;
        var number = double.parse(rawNumber);
        if (lastFunction.isEmpty) {
          result = number;
        } else {
          switch (lastFunction) {
            case "+":
              result += number;
            case "-":
              result -= number;
            case "*":
              result *= number;
            case "/":
              result /= number;
          }
          lastFunction = "";
        }
        exp = exp.replaceFirst(rawNumber, "");
      } else {
        lastFunction = functionRegex.firstMatch(exp)![0]!;
        exp = exp.replaceFirst(lastFunction, "");
      }

      isFunctionTurn = !isFunctionTurn;
    }

    expression.value = result.toString();
  }
}

class Calculator extends StatelessWidget {
  static const Color NUMBER_BUTTON_COLOR = Color(0xffc2e3f2);
  static const Color FUNCTION_BUTTON_COLOR = Color(0xfff2e5c2);

  Widget createButton(digit,
      {required size, required VoidCallback onTap, isFunction = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFunction ? FUNCTION_BUTTON_COLOR : NUMBER_BUTTON_COLOR),
        child: Center(
          child: Text(
            "$digit",
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CalculatorController controller = Get.put(CalculatorController());

    var size = MediaQuery.of(context).size;

    var buttonSize = size.width / 5;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Obx(() => Text(
                  "${controller.expression}",
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 64),
                )),
            const SizedBox(height: 15),
            TextButton(
                onPressed: controller.clear,
                child: Text("AC", style: TextStyle(fontSize: 32))),
            Wrap(
              children: [
                ...List.generate(10, (index) => index).map((e) => createButton(
                    e,
                    size: buttonSize,
                    onTap: () => controller.append("$e.0"))),
                ...["+", "-", "*", "/"].map((e) => createButton(e,
                    size: buttonSize,
                    onTap: () => controller.append(e),
                    isFunction: true)),
                createButton("=", size: buttonSize, onTap: () {
                  controller.calculateResult();
                }, isFunction: true)
              ],
            )
          ],
        ),
      ),
    );
  }
}

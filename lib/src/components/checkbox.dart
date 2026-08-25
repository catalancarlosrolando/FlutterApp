import 'package:flutter/material.dart';

class MiCheckbox extends StatefulWidget {
  const MiCheckbox({super.key});

  @override
  State<MiCheckbox> createState() => MiCheckboxState();
}

class MiCheckboxState extends State<MiCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isChecked,
      onChanged: (bool? nuevoValor) {
        setState(() {
          isChecked = nuevoValor ?? false;
        });
      },
    );
  }
}

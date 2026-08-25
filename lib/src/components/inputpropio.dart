import 'package:flutter/material.dart';

class Inputpropio extends StatelessWidget {
  final String text;

  const Inputpropio({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: "",
        hintText: text,
        filled: true,
        fillColor: Colors.grey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
    );
  }
}

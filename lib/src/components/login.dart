import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/buttonpropio.dart';
import 'package:flutter_application/src/components/checkbox.dart';

import 'package:flutter_application/src/components/inputpropio.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Username", style: TextStyle(color: Colors.white))],
          ),
          SizedBox(height: 12.0),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Inputpropio(text: "whathever...."),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Password", style: TextStyle(color: Colors.white))],
          ),
          SizedBox(height: 12.0),
          Inputpropio(text: "your super secret pass"),
          SizedBox(height: 36.0, width: 200.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MiCheckbox(),
                  Text(
                    "Remember me",
                    style: TextStyle(color: colors.onPrimary),
                  ),
                ],
              ),

              Text(
                "Forgot password?",
                style: TextStyle(
                  color: colors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primary,
                  decorationThickness: 2.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 36.0, width: 200.0),
          BotonPropio(),
        ],
      ),
    );
  }
}

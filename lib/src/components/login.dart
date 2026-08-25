import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_application/src/components/buttonpropio.dart';
import 'package:flutter_application/src/components/checkbox.dart';

import 'package:flutter_application/src/components/inputpropio.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text("Remember me", style: TextStyle(color: Colors.white)),
                ],
              ),

              Text(
                "Forgot password?",
                style: TextStyle(
                  color: Colors.yellow,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.yellow,
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

import "package:flutter/services.dart"
    show rootBundle; //el show importa solo la clase necesaria

import 'dart:convert';

class _RoutineProvider {
  Map<String, dynamic> rutinas = {};

  _RoutineProvider();
  Future<Map<String, dynamic>> cargarData() async {
    final resp = await rootBundle.loadString("data/routines.json");
    Map<String, dynamic> dataMap = json.decode(resp);
    rutinas = dataMap["routines"] ?? {};
    return rutinas;
  }
}

final routineProvider = _RoutineProvider();

import 'package:flutter/material.dart';

class AlertPage extends StatelessWidget {
  const AlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('alerta')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _mostrarAlerta(context),
          child: Text("Mostrar alera"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _mostrarAlerta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text("Titulo de la Alerta"),
          content: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            children: [Text("contenide de la alerta"), FlutterLogo(size: 100)],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}

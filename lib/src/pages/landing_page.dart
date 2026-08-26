import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final String title;
  const LandingPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        leading: IconButton(
          icon: ImageIcon(const AssetImage('assets/images/logo.png')),
          iconSize: 60.0,
          color: Colors.amber,
          onPressed: () {
            // Navegar a la página anterior
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blueGrey[900],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(title, style: TextStyle(color: Colors.amber)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              'Bienvenido a la Landing Page',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

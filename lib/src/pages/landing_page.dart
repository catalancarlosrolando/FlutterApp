import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/lastday.dart';

class LandingPage extends StatelessWidget {
  final String title;
  const LandingPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: ImageIcon(const AssetImage('assets/images/logo.png')),
          iconSize: 60.0,
          color: Colors.amber,
          onPressed: () {
            // Navegar a la página anterior
            Navigator.pop(context);
          },
        ),

        title: Center(
          child: Text(title, style: TextStyle(color: colors.onPrimary)),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            LastDay(),
            Container(
              height: 150.0,
              width: 500,
              //color: colors.primaryContainer,
              padding: const EdgeInsets.all(12.0),
              margin: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Ultima Asistencia"), Text('14 de mayo 2026')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

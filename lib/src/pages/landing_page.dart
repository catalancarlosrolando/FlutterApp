import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/endDrawer.dart';
import 'package:flutter_application/src/components/lastday.dart';
import 'package:flutter_application/src/components/nextRoutine.dart';
import 'package:flutter_application/src/components/stepsToday.dart';

class LandingPage extends StatefulWidget {
  final String title;
  const LandingPage({super.key, required this.title});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: ImageIcon(const AssetImage('assets/images/logo.png')),
          iconSize: 60.0,
          color: Colors.amber,
          onPressed: () {
            // Navegar a la página anterior
            Navigator.pop(context);
          },
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola Camila",
              style: TextStyle(fontSize: 20.0, color: colors.onSurface),
            ),
            Text(
              "Retoma donde lo dejaste",
              style: TextStyle(fontSize: 12.0, color: colors.onSurface),
            ),
          ],
        ),
      ),
      endDrawer: MyEndDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 24.0,
            children: [LastDay(), StepsToday(), NextRoutine()],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<MyNavigationBar> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: NavigationBar(
          onDestinationSelected: widget.onDestinationSelected, //callback,
          indicatorColor: colors.primary,
          indicatorShape: CircleBorder(eccentricity: 0.7),
          selectedIndex: widget.currentIndex,
          destinations: const <Widget>[
            //destinos es una lista de destinos
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.fitness_center),
              label: 'Rutinas',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

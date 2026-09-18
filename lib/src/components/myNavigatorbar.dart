import 'package:flutter/material.dart';
import 'package:flutter_application/src/components/mybuttonnavigator.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 60.0,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: colors.outline, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyButtonNavigator(
                text: 'Home',
                icon: Icons.home,
                isSelected: currentIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              MyButtonNavigator(
                text: 'Rutinas',
                icon: Icons.list,
                isSelected: currentIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
